// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC1155.sol";
import "./IERC1155TokenReceiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title Standard ERC1155 token
 *
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 */
contract ERC1155 is ERC165, IERC1155 {
    using Address for address;

    // Mapping from token ID to owner balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Interface IDs
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
    bytes4 private constant _INTERFACE_ID_ERC1155_TOKEN_RECEIVER = 0x4e2312e0;

    constructor() {
        // No need to register interface as we're implementing supportsInterface
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == _INTERFACE_ID_ERC1155 ||
            interfaceId == _INTERFACE_ID_ERC1155_TOKEN_RECEIVER ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner, uint256 id) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][owner];
    }

    function balanceOfBatch(
        address[] memory owners,
        uint256[] memory ids
    ) public view virtual override returns (uint256[] memory) {
        require(owners.length == ids.length, "ERC1155: owners and IDs must have same lengths");

        uint256[] memory batchBalances = new uint256[](owners.length);

        for (uint256 i = 0; i < owners.length; ++i) {
            require(owners[i] != address(0), "ERC1155: some address in batch balance query is zero");
            batchBalances[i] = _balances[ids[i]][owners[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) external virtual override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external virtual override {
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || _operatorApprovals[from][msg.sender] == true,
            "ERC1155: need operator approval for 3rd party transfers."
        );

        _balances[id][from] -= value;
        _balances[id][to] += value;

        emit TransferSingle(msg.sender, from, to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external virtual override {
        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || _operatorApprovals[from][msg.sender] == true,
            "ERC1155: need operator approval for 3rd party transfers."
        );

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            _balances[id][from] -= value;
            _balances[id][to] += value;
        }

        emit TransferBatch(msg.sender, from, to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, values, data);
    }

    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
        require(to != address(0), "ERC1155: mint to the zero address");

        _balances[id][to] += value;
        emit TransferSingle(msg.sender, address(0), to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, value, data);
    }

    function _batchMint(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal {
        require(to != address(0), "ERC1155: batch mint to the zero address");
        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");

        for(uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += values[i];
        }

        emit TransferBatch(msg.sender, address(0), to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), to, ids, values, data);
    }

    function _burn(address owner, uint256 id, uint256 value) internal {
        _balances[id][owner] -= value;
        emit TransferSingle(msg.sender, owner, address(0), id, value);
    }

    function _batchBurn(address owner, uint256[] memory ids, uint256[] memory values) internal {
        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");

        for(uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][owner] -= values[i];
        }

        emit TransferBatch(msg.sender, owner, address(0), ids, values);
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) internal {
        if(to.isContract()) {
            try IERC1155TokenReceiver(to).onERC1155Received(operator, from, id, value, data) returns (bytes4 response) {
                require(
                    response == _INTERFACE_ID_ERC1155_TOKEN_RECEIVER,
                    "ERC1155: ERC1155Receiver rejected tokens"
                );
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal {
        if(to.isContract()) {
            try IERC1155TokenReceiver(to).onERC1155BatchReceived(operator, from, ids, values, data) returns (bytes4 response) {
                require(
                    response == _INTERFACE_ID_ERC1155_TOKEN_RECEIVER,
                    "ERC1155: ERC1155Receiver rejected tokens"
                );
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }
}

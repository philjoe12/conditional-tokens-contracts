// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC1155TokenReceiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract ERC1155TokenReceiver is ERC165, IERC1155TokenReceiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155TokenReceiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual override returns(bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual override returns(bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
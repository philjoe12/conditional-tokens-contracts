// contracts/Forwarder.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/ERC1155/IERC1155TokenReceiver.sol";

contract Forwarder is IERC1155TokenReceiver {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // Implement your logic here
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // Implement your logic here
        return this.onERC1155BatchReceived.selector;
    }

    // Implement supportsInterface as required by IERC165
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC1155TokenReceiver).interfaceId;
    }
}

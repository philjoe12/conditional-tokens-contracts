// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/ERC1155/ERC1155.sol";

contract ERC1155Mock is ERC1155 {
    function mint(address to, uint256 id, uint256 value, bytes memory data) public {
        _mint(to, id, value, data);
    }

    function batchMint(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) public {
        _batchMint(to, ids, values, data);
    }

    function burn(address owner, uint256 id, uint256 value) public {
        _burn(owner, id, value);
    }

    function batchBurn(address owner, uint256[] memory ids, uint256[] memory values) public {
        _batchBurn(owner, ids, values);
    }
}
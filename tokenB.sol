// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {

    constructor() ERC20("TokenB", "B") {
        _mint(msg.sender, 20000 * (10**18) );
    }
}
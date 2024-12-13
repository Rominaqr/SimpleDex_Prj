// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {

   /* constructor() ERC20("TokenA", "TA") {
        _mint(msg.sender, 1000 * 10 ** decimals()); // Mint 10000 TA
    }*/

    constructor(address _initialAccount) ERC20("TokenA", "TA") {
        require(_initialAccount != address(0), "La direccion no puede ser 0");
        _mint(_initialAccount, 1000 * 10 ** decimals()); // Mint 1000 TA a la cuenta proporcionada
    }

}


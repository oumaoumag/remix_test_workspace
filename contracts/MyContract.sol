// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

contract MyContract {
    uint public myValue;

    constructor(uint _initialValue) {
        myValue = _initialValue;
    }

    function getValue() public view returns (uint) {
        return myValue;
    }
}

contract ContractDeployer {
    MyContract public deployedContract;
}
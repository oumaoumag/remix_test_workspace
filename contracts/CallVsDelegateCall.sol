// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

contract ContractB {
    uint public valueB = 10;

    function setValue(uint _newValue) public {
        valueB = _newValue;
    }
}

abstract contract contractA {
    ContractB public contractB;
    uint public valueA = 20;

      constructor(address _contractBAddress) {
        contractB  = ContractB(_contractBAddress);
    }

    function interactiveWith(uint _newValue) public {
        (bool success, bytes memory data) = address(contractB).call(
            abi.encodeWithSignature("setValue(uint256)", _newValue)
        );
        require(success, "Call field");
    }
}
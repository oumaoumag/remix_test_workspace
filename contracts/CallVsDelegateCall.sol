// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

contract ContractB {
    uint public valueB = 10;

    // Updates the valueB state variable with a new value
    function setValue(uint _newValue) public {
        valueB = _newValue;
    }
}

// Abstract contract that interacts with ContractB
abstract contract contractA {
    // Reference to an instance of ContractB
    ContractB public contractB;

    // Public state variable to store a value, initialized to 20
    uint public valueA = 20;

    // Constructor: Initializes contractB with the provided ContractB address
      constructor(address _contractBAddress) {
        contractB  = ContractB(_contractBAddress);
    }

    // Calls setValue on ContractB to update its valueB using a low-level call
    function interactiveWith(uint _newValue) public {
        (bool success, ) = address(contractB).call(
            abi.encodeWithSignature("setValue(uint256)", _newValue)
        );
        // Revertz if the call fails
        require(success, "Call field");
    }
}

// Library with a function to update a mapping
library ContractL {
    // Update a mapping with a new value for the given key
    function setValue(mapping(uint => uint) storage valueMap, uint _value, uint _newValue) internal {
        valueMap[_value] = _newValue;
    }
}

// Interacts with ContractL using delegateCall to update a mapping
contract ContractC {
    // Public mapping to store key-value pairs
    mapping(uint => uint) public valueMap;

    // Public state variable, initializzedd to 30
    uint public valueC = 30;

    // Uses delegatacall to call setValue in ContractL, updating valueMap
    function interactingWithL(address _contractLAddress, uint _newValue) public {
        (bool success, ) = _contractLAddress.delegatecall(
            abi.encodeWithSignature("setValue(uint256, uint256)", valueC, _newValue)
        );
        // Reverts if the delegatecall fails
        require(success, "Delegatecall failed");
     }
}
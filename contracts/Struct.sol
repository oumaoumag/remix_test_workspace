// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Base contract for inheritance
contract Parent {
    // Virtual function to be overridden
    function sayHello() public pure virtual returns (string memory) {
        return "Hello from Parent";
    }
}

// Main contract with storage, memory, and calldata examples
contract SchoolRecord is Parent {
    // Public state variable
    uint public number;

    // Student struct
    struct Student {
        string name;
        uint age;
        string country;
        string major;
    }

    // Mapping for student records
    mapping(uint => Student) public students;

    // Updates the number state variable
    function setNumber(uint _number) public {
        number = _number;
    }

    // Adds a student to the mapping
    function addStudent(uint _id, string memory _name, uint _age, string memory _country, string memory _major) public {
        students[_id] = Student(_name, _age, _country, _major);
    }

    // Fetches student data into a memory variable
    function getStudent(uint _id) public view returns (string memory, uint, string memory, string memory) {
        Student memory s = students[_id];
        return (s.name, s.age, s.country, s.major);
    }

    // Uses calldata for gas savings
    function setNumberWithCalldata(uint _number) external {
        number = _number;
    }

    // Overrides parent's sayHello
    function sayHello() public pure override returns (string memory) {
        return "Hello from SchoolRecord";
    }

    // Calls parent's sayHello with super
    function callParentHello() public pure returns (string memory) {
        return super.sayHello();
    }
}
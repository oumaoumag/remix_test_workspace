// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// Error definitions
error InvalidAge();          // Age not between 18 and 40
error PlayerNotFound();      // No active player with given ID
error PlayerAlreadyExists(); // Trying to add a player with an ID that exists
error EmptyName();           // Name string is empty

contract PlayerRegistry is Ownable {
    enum ExperienceLevel { Rookie, Pro, Veteran }  // Player skill levels

    struct Player {
        uint id;                  // Unique player ID
        string name;             
        uint age;                
        ExperienceLevel experience; // Skill level
        bool isActive;           
    }

    Player[] public players;              // List of players
    mapping(uint => bool) public playerExists;  // Track existing IDs
    uint public playerCount;              // Next ID to assign

    event PlayerAdded(uint indexed playerId, string name, ExperienceLevel experience);
    event PlayerUpdated(uint indexed playerId, ExperienceLevel newExperience);
    event PlayerRemoved(uint indexed playerId);

    constructor() Ownable(msg.sender) {}  // Set contract owner

    // Add a new player; only owner can call
    function addPlayer(string memory name, uint age, ExperienceLevel experience) external onlyOwner {
        if (bytes(name).length == 0) revert EmptyName();          
        if (age < 18 || age > 40) revert InvalidAge();            
        if (playerExists[playerCount]) revert PlayerAlreadyExists(); 

        players.push(Player(playerCount, name, age, experience, true));
        playerExists[playerCount] = true;  
        emit PlayerAdded(playerCount, name, experience);
        playerCount++;                     
    }

    // Update experience; only owner
    function updatePlayerExperience(uint playerId, ExperienceLevel newExperience) external onlyOwner {
        if (!playerExists[playerId] || !players[playerId].isActive) revert PlayerNotFound();
        players[playerId].experience = newExperience;  // Change level
        emit PlayerUpdated(playerId, newExperience);
    }

    // Remove a player; only owner
    function removePlayer(uint playerId) external onlyOwner {
        if (!playerExists[playerId] || !players[playerId].isActive) revert PlayerNotFound();

        // Swap-remove from array
        for (uint i = 0; i < players.length; i++) {
            if (players[i].id == playerId) {
                players[i] = players[players.length - 1];
                players.pop();
                break;
            }
        }
        playerExists[playerId] = false;  // Mark ID free
        emit PlayerRemoved(playerId);
    }

    // Get all active players
    function getPlayers() external view returns (Player[] memory) {
        return players;
    }
}

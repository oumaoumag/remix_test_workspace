// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title EtherVault
 * @dev A fun game contract for teaching Solidity concepts. Players must send Ether via selfdestruct or deposit,
 * solve challenges to increase their withdrawal limits, and withdraw Ether after a lock period.
 * The contract owner manages the whitelist. See instructions: `https://tinyurl.com/EtherVault`
 */
contract EtherVault {
    /** @dev Contract owner (deployer) */
    address public owner;

    /** @dev Deployment timestamp and lock period (2 days) */
    uint public deploymentTime = block.timestamp;
    uint public constant LOCK_PERIOD = 2 days;

    /** @dev Withdrawal limits per role */
    uint public constant WHITELISTED_WITHDRAWAL = 0.0005 ether;
    uint public constant MAGIC_WORD_WITHDRAWAL = 0.001 ether;
    uint public constant BIG_SPENDER_WITHDRAWAL = 0.003 ether;

    /** @dev Big Spender threshold (0.03 ether) */
    uint public constant BIG_SPENDER_THRESHOLD = 0.03 ether;

    /** @dev Magic word hash */
    bytes32 public constant MAGIC_WORD_HASH = 0xe12a28df6f8731c94ade6605c8f457c16b3f591ecc3be3d092af1f56215a3da2;

    /** @dev Track Ether sent and withdrawn per address */
    mapping(address => uint) public etherSent;
    mapping(address => uint) public etherWithdrawn;

    /** @dev Role tracking */
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public guessedMagicWord;

    /** @dev Last withdrawal tracking */
    address public lastWithdrawer;
    uint public lastWithdrawalTime;
    uint public constant WITHDRAWAL_DELAY = 1 hours; // 1-hour cooldown

    /** @dev Event for transparency */
    event Withdrawn(address indexed user, uint amount);
    event Whitelisted(address indexed user, bool status);

    /** @dev Constructor sets the deployer as the owner */
    constructor() {
        owner = msg.sender;
    }

    /** @dev Modifier to restrict functions to the contract owner */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Add multiple addresses to the whitelist.
     * @param _users Array of addresses to whitelist.
     */
    function addToWhitelist(address[] calldata _users) external onlyOwner {
        for (uint i = 0; i < _users.length; i++) {
            isWhitelisted[_users[i]] = true;
            emit Whitelisted(_users[i], true);
        }
    }

    /**
     * @dev Remove multiple addresses from the whitelist.
     * @param _users Array of addresses to remove from the whitelist.
     */
    function removeFromWhitelist(address[] calldata _users) external onlyOwner {
        for (uint i = 0; i < _users.length; i++) {
            isWhitelisted[_users[i]] = false;
            emit Whitelisted(_users[i], false);
        }
    }

    /**
     * @dev Check if an address is whitelisted.
     * @param _user The address to check.
     * @return bool True if the address is whitelisted, false otherwise.
     */
    function checkWhitelistStatus(address _user) external view returns (bool) {
        return isWhitelisted[_user];
    }

    /**
     * @dev Deposit Ether to be recognized as a big spender.
     * Only allows deposits of at least 0.01 ether.
     */
    function deposit() external payable {
        require(msg.value >= BIG_SPENDER_THRESHOLD, "Deposit must be at least 0.03 ether");
        etherSent[msg.sender] += msg.value;
    }

    /**
     * @dev Guess the magic word ("Solidity") to unlock higher withdrawals.
     * @param _word The word to guess.
     */
    function guessMagicWord(string memory _word) external {
        require(keccak256(abi.encodePacked(_word)) == MAGIC_WORD_HASH, "Wrong guess");
        guessedMagicWord[msg.sender] = true;
    }

    /**
     * @dev Determine the user's withdrawal limit based on their role.
     * @param _user The address of the user.
     * @return The withdrawal limit for the user.
     */
    function getWithdrawalLimit(address _user) public view returns (uint) {
        if (etherSent[_user] >= BIG_SPENDER_THRESHOLD) {
            return BIG_SPENDER_WITHDRAWAL;
        } else if (guessedMagicWord[_user]) {
            return MAGIC_WORD_WITHDRAWAL;
        } else if (isWhitelisted[_user]) {
            return WHITELISTED_WITHDRAWAL;
        } else {
            revert("Not eligible for withdrawal");
        }
    }

    /**
     * @dev Check if the user can withdraw at the current time.
     * @param _user The address of the user.
     * @return bool True if the user can withdraw, false otherwise.
     */
    function canWithdraw(address _user) external view returns (bool) {
        if (block.timestamp < deploymentTime + LOCK_PERIOD) {
            return false;
        }
        if (_user == lastWithdrawer && block.timestamp < lastWithdrawalTime + WITHDRAWAL_DELAY) {
            return false;
        }
        if (!isWhitelisted[_user] && !guessedMagicWord[_user] && etherSent[_user] < BIG_SPENDER_THRESHOLD) {
            return false;
        }
        
        return true;
    }

    /**
     * @dev Withdraw Ether based on the user's role after the lock period.
     */
    function withdraw() external {
        require(block.timestamp >= deploymentTime + LOCK_PERIOD, "Withdrawals are locked");
        require(
            msg.sender != lastWithdrawer || block.timestamp >= lastWithdrawalTime + WITHDRAWAL_DELAY,
            "Last withdrawer must wait 1 hour"
        );

        uint limit = getWithdrawalLimit(msg.sender);
        require(address(this).balance >= limit, "Insufficient balance in vault");

        lastWithdrawer = msg.sender;
        lastWithdrawalTime = block.timestamp;

        etherWithdrawn[msg.sender] += limit;
        (bool sent, ) = msg.sender.call{value: limit}("");
        require(sent, "Failed to send Ether");

        emit Withdrawn(msg.sender, limit);
    }

    /**
     * @dev Check the contract's current balance.
     * @return The balance of the contract.
     */
    function getVaultBalance() external view returns (uint) {
        return address(this).balance;
    }

    /**
     * @dev Fallback function to receive Ether via selfdestruct.
     */
    receive() external payable {}
}
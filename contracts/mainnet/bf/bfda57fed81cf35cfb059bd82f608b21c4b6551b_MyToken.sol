/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// File: contracts/new.sol


pragma solidity ^0.8.0;

contract MyToken {
    string public name = "ELON";
    string public symbol = "ELON";
    uint256 public totalSupply = 10000000000 * 10**18;
    uint8 public decimals = 18;
    bool public isMintable = false;
    bool public antiBotEnabled = true;
    address public owner;


    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isExcludedFromAntiBot; 

    

    uint256 public totalFeesCollected;
    uint256 public feePercent = 0;




    
 // Added variable to track if the contract is locked or not
    bool public isLocked = false;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FeesCollected(address indexed collector, uint256 value);
    event AntiBotEnabled(bool enabled);

   modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }



    constructor() {
        balanceOf[msg.sender] = totalSupply;
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromAntiBot[msg.sender] = true;
        isExcludedFromAntiBot[address(this)] = true;


    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(!isLocked, "The contract is locked");

        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!isLocked, "The contract is locked");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(!isLocked, "The contract is locked");

        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;

    }
    
    
    
    function enableAntiBot() external {
        require(!antiBotEnabled, "Anti-bot is already enabled");
        require(isExcludedFromAntiBot[msg.sender], "You are not allowed to enable anti-bot");
        antiBotEnabled = true;
        emit AntiBotEnabled(true);
    }
    


    modifier mintable() {
        require(isMintable, "Minting is not allowed for this token");
        _;
    }

    function mint(address _to, uint256 _amount) public mintable {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
    }
    

  // Added function to lock the contract and prevent bots from buying more tokens
    function lockContract() public {
        isLocked = true;
    }

    // Added function to unlock the contract and allow token transfers again
    function unlockContract() public {
        isLocked = false;
    }


  function renounceOwnership() public onlyOwner {
        owner = address(0);
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }


    
    // Additional statements
    string public constant additionalStatement1 = "This contract is not mintable.";
    string public constant additionalStatement2 = "This contract does not have a function to take back ownership.";
    string public constant additionalStatement3 = "This contract is not hidden owner.";
    string public constant additionalStatement4 = "This contract cannot self-destruct.";
    uint8 public constant buyTax = 0;
    uint8 public constant sellTax = 0;
}
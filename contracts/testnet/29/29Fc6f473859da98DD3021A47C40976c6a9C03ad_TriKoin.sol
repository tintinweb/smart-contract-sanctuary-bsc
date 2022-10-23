// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract TriKoin {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;
    address payable public owner;

    string private secret;

    /* This creates a mapping with all balances */
    mapping(address => uint256) public balanceOf;

    /* Allowed tokens to all the users */
    mapping(address => uint256) public approvedToken;

    /* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed from, address indexed to, uint256 value);

    constructor() {
        name = "TriKoin";
        symbol = "TRIKOIN";
        decimals = 18;
        secret = "triKoin";
        uint256 _initialSupply = 100 * 1000 * 1000 * 1000 * 10**decimals; // 100 Billion

        /* Sets the owner of the token to whoever deployed it */
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        totalSupply = _initialSupply; // Sets the total supply of tokens

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(
            senderBalance > _value,
            "You do not have enough TriKoins to send"
        );

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approveToken(uint256 _value, string memory _secret)
        public
        returns (bool success)
    {
        uint256 tokens = _value * 10**decimals;
        require(tokens > 0, "TriKoins must be greater than 0");
        bool condition = keccak256(abi.encodePacked(_secret)) ==
            keccak256(abi.encodePacked(secret));
        require(condition, "Invalid Secret Key");

        approvedToken[msg.sender] += tokens;

        emit Approve(owner, msg.sender, tokens);
        return true;
    }

    function withdrawToken(uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[owner];
        uint256 receiverBalance = balanceOf[msg.sender];
        uint256 fromAllowance = approvedToken[msg.sender];

        require(_value >= 0, "Value must be greater or equal to 0");
        require(
            senderBalance > _value,
            "The contract has reached the maxmium limit."
        );
        require(
            fromAllowance >= _value,
            "You are not allowed to withdraw TriKoins. Kindly approve the transaction first."
        );

        balanceOf[owner] = senderBalance - _value;
        balanceOf[msg.sender] = receiverBalance + _value;
        approvedToken[msg.sender] = fromAllowance - _value;

        emit Transfer(owner, msg.sender, _value);
        return true;
    }

    function mint(uint256 _amount) public onlyOwner returns (bool success) {
        totalSupply += _amount;
        balanceOf[owner] += _amount;

        emit Transfer(address(0), owner, _amount);
        return true;
    }

    function burn(uint256 _amount) public onlyOwner returns (bool success) {
        uint256 accountBalance = balanceOf[owner];
        require(accountBalance > _amount, "Burn amount exceeds balance");

        balanceOf[owner] -= _amount;
        totalSupply -= _amount;

        emit Transfer(owner, address(0), _amount);
        return true;
    }

    function setSecret(string memory _secret) public onlyOwner {
        secret = _secret;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }
}
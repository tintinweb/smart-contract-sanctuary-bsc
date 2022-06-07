/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {_status = _NOT_ENTERED;}
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract PLRTDistribution is ReentrancyGuard {
    address public owner = 0xBEED5427b0E728AC7EfAaD279c51d511472f9ee2; // owner tx with function to gnosis multisig
    IERC20 public token; //  PLRT erc20 Token.
    bool private tokenAvailable = false;// stop some things until we know where the token is
    bool public vestingStarted = false; //started or not
    uint public cooldownTime = 10 days; // time between withdrawals of token
    uint256 internal balance;//var for what the CONTRACT actually holds

    mapping(address => bool) public whitelist; // Whitelist for presale.
    mapping(address => uint) public investorBalance;//their current balance
    mapping(address => uint) public withdrawableBalance;//how much they can take out of tha platform
    mapping(address => uint) public claimReady;//is it time for that to happen

    constructor() {
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'You must be the owner.');
        _;
    }

    //used to change owner of this contract = send to multisig
    function transferOwnership (address newOwner) public onlyOwner {
        if (newOwner != 0x0000000000000000000000000000000000000000){
        owner = newOwner;
        }
    }

    ///tell this contract about PLRT erc20
    function setToken(IERC20 _token) public onlyOwner {
        require(!tokenAvailable, "Token is already inserted.");
        token = _token;
        tokenAvailable = true;
    }

    ////ADD them with pass 1 address per pass owned
    function AddToWhitelist(address[] memory _investor) public onlyOwner {
        for (uint _i = 0; _i < _investor.length; _i++) {
            require(_investor[_i] != address(0), 'Invalid address.');
            address _investorAddress = _investor[_i];
            whitelist[_investorAddress] = true;
            investorBalance[_investorAddress] += 20000*10**18; 
        }
    }

    //START
    function startVesting() public onlyOwner {
        require(tokenAvailable, "Token is not set.");
        require(!vestingStarted, "vesting already started.");
        vestingStarted = true;
    }

    //% calculation of percentage
    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    //it means a buyer who buys 1000 tokens can take 100 a week every week for x weeks
    function withdrawTokens() public nonReentrant {
        require(whitelist[msg.sender], "You must be on the whitelist.");
        require(token.balanceOf(address(this)) > 0, "Insufficient balance.");
        require(claimReady[msg.sender] <= block.timestamp, "You can't claim now.");
        require(investorBalance[msg.sender] > 0, "Insufficient investor balance.");

        uint _withdrawableTokensBalance = mulScale(investorBalance[msg.sender], 1000, 10000); // 1000 basis points = 10%.

        if(withdrawableBalance[msg.sender] <= _withdrawableTokensBalance) {
            token.transfer(msg.sender, withdrawableBalance[msg.sender]);
            investorBalance[msg.sender] = 0;
            withdrawableBalance[msg.sender] = 0;
        } else {
            claimReady[msg.sender] = block.timestamp + cooldownTime; // update next claim time
            withdrawableBalance[msg.sender] -= _withdrawableTokensBalance; // update withdrawable balance
            token.transfer(msg.sender, _withdrawableTokensBalance); // transfer the tokens
        }
    }

    receive() external payable{
        balance += msg.value;
    }

    fallback() external payable{
        balance += msg.value;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function onERC20Received(address _operator, address _from, uint256 _value, bytes calldata _data) external returns(bytes4);
}
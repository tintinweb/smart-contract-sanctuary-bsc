/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.5.0;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function increaseAllowance(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract ICO {
    
    uint256 public totalSupply;
    uint256 public total_ico = 0;
    struct ico_struct{
        uint256 id;
        IERC20 stakingToken;
        IERC20 stakingFromToken;
        uint256 ratePerToken;
        uint40 startTime;
        uint40 endTime;
        uint256 totalSupply;
        uint256 totalSale;
        bool status;
    }

    // mappings
    mapping (uint256 => ico_struct) public ICOs;   
    uint256 public totalSale;
    address payable private admin;  

    modifier onlyOwner() {
        require(msg.sender == admin, "Message sender must be the contract's owner.");
        _;
    }
    
    event Buy(address indexed buyer, uint256 indexed spent, uint256 indexed recieved);
    event Claim(address indexed recipient, uint256 indexed claimed);
    event Create(address indexed recipient, uint256 indexed claimed);

    constructor () public {
        admin = msg.sender;
        totalSale = 0;
        totalSupply = 1000000;
    }

    function create_ICO(IERC20 _stakingToken, IERC20 _stakingFromToken, uint40 _startTime, uint40 _endTime, uint256 _totalSupply, uint256 _ratePerToken) public returns(bool){
        total_ico++;
        ICOs[total_ico].id = total_ico;
        ICOs[total_ico].stakingToken = _stakingToken;
        ICOs[total_ico].stakingFromToken = _stakingFromToken;
        ICOs[total_ico].startTime = _startTime;
        ICOs[total_ico].endTime = _endTime;
        ICOs[total_ico].totalSupply = _totalSupply;
        ICOs[total_ico].ratePerToken = _ratePerToken;
        ICOs[total_ico].status = true;
    }

    /**
     * @dev See {IERC20-buy}.
     *
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
    */    
     
    function buy(uint256 amount,uint256 _icoid) public returns (bool) {
        _buy(msg.sender, amount, _icoid);
        return true;
    }
    
    function _buy(address sender, uint256 amount, uint256 _ico) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(amount > 0, "BEP20: Amount Should be greater then 0!");        
        require(amount <= ICOs[_ico].stakingFromToken.balanceOf(sender), "BEP20: Insufficient Fund!");
        uint256 tokens = amount * ICOs[_ico].ratePerToken;
        require((ICOs[_ico].totalSupply-ICOs[_ico].totalSale) >= tokens, "Insufficient Tokens in ICO.");
        require((totalSupply-totalSale) >= tokens, "Insufficient Tokens in ICO.");
        //stakingFromToken.increaseAllowance(address(this), amount); 
        ICOs[_ico].stakingFromToken.transferFrom(msg.sender, admin, amount * (10 ** 18));
        ICOs[_ico].stakingToken.transfer(sender, tokens * (10 ** 18));
        ICOs[_ico].totalSale += tokens;
        totalSale += tokens;
        //_transfer(address(this), sender, tokens * (10 ** uint256(decimals())));        
        // emit Buy(sender, amount, tokens);
    }
    
    function changeStatus(bool _status, uint256 _icoid) public onlyOwner returns (bool) {
        ICOs[_icoid].status = _status;
        //stakingFromToken.transferFrom(msg.sender, recipient, amount);
        return true;
    }

    function addSupply(uint256 _amnt) public onlyOwner returns (bool) {
        totalSupply += _amnt;
        //stakingFromToken.transferFrom(msg.sender, recipient, amount);
        return true;
    }

    function getTotalSupply() public view returns(uint256){
        return totalSupply;
    }
    function getTotalSale() public view returns(uint256){
        return totalSale;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-06-26
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
    
    IERC20 public stakingToken;
        
    uint256 public ratePerBNB;

    address payable private admin;  

    modifier onlyOwner() {
        require(msg.sender == admin, "Message sender must be the contract's owner.");
        _;
    }

    event Buy(address indexed buyer, uint256 indexed spent, uint256 indexed recieved);
    event Claim(address indexed recipient, uint256 indexed claimed);

    constructor (address _stakingToken) public {
        
        stakingToken = IERC20(_stakingToken);
        
        
        ratePerBNB = 1000;
        admin = msg.sender;
    }    
    
    /**
     * @dev See {IERC20-buy}.
     *
     * Requirements:
     *
     * - the caller must have a balance of at least `amount`.
     */
    function buyFromBNB() public payable returns (bool) {
        require(msg.value > 0, "BEP20: BNB should be greater then 0.");
        _buyFromBNB(msg.sender, msg.value);
        return true;

    }
    
    function _buyFromBNB(address sender, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");               
        uint256 tokensbnb = amount * ratePerBNB;
        
        stakingToken.transfer(sender, tokensbnb);
        admin.transfer(amount);
        //_transfer(address(this), sender, tokensbnb);        
       //emit Buy(sender, amount, tokensbnb);
    }

    function ratePerBNBChange(uint256 _ratePerBNB) public onlyOwner returns (bool) {
        ratePerBNB = _ratePerBNB;
        //stakingFromToken.transferFrom(msg.sender, recipient, amount);
        return true;
    }

     
}
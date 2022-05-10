/**
 *Submitted for verification at BscScan.com on 2022-05-10
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
        uint256 minPurchase;
        bool status;
    }

    uint32 stakingTime = 10000;

    struct user_purchases{
        uint256 tokens;
        uint256 claimed;
    }

    uint256 total_investments = 0;
    struct investment{
        uint256 ico;
        address myaddress;
        uint256 tokens;
        bool status;
        uint32 stakingTime ;
    }

    
    struct my_invs{
        uint256 total_investments;
        uint256[] myinvestments;
    }
    // mappings
    mapping (uint256 => investment) public investments;
    mapping (uint256 => ico_struct) public ICOs;   
    mapping (address => user_purchases) public User_purchase;   
    mapping (address => my_invs) public my_investments;   
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

        total_ico++;
        ICOs[total_ico].id = total_ico;
        ICOs[total_ico].stakingToken = IERC20(0x74D509Ee44d380BC78685C8aBd9d159E402E234D);
        ICOs[total_ico].stakingFromToken = IERC20(0x325a4deFFd64C92CF627Dd72d118f1b8361c5691);
        ICOs[total_ico].startTime = uint32(block.timestamp);
        ICOs[total_ico].endTime = uint32(block.timestamp + 1000000);
        ICOs[total_ico].totalSupply = 100000;
        ICOs[total_ico].ratePerToken = 10;
        ICOs[total_ico].minPurchase = 1;
        ICOs[total_ico].status = true;

    }

    function create_ICO(IERC20 _stakingToken, IERC20 _stakingFromToken, uint40 _startTime, uint40 _endTime, uint256 _totalSupply, uint256 _ratePerToken, uint256 _minPurchase) public returns(bool){
        total_ico++;
        ICOs[total_ico].id = total_ico;
        ICOs[total_ico].stakingToken = _stakingToken;
        ICOs[total_ico].stakingFromToken = _stakingFromToken;
        ICOs[total_ico].startTime = _startTime;
        ICOs[total_ico].endTime = _endTime;
        ICOs[total_ico].totalSupply = _totalSupply;
        ICOs[total_ico].ratePerToken = _ratePerToken;
        ICOs[total_ico].minPurchase = _minPurchase;
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
       // ICOs[_ico].stakingToken.transfer(sender, tokens * (10 ** 18));
        ICOs[_ico].totalSale += tokens;
        totalSale += tokens;

        total_investments ++;
        investments[total_investments].myaddress = msg.sender;
        investments[total_investments].tokens = tokens;
        investments[total_investments].status = true;
        investments[total_investments].ico = _ico;
        investments[total_investments].stakingTime = uint32(block.timestamp + stakingTime);        

        my_investments[msg.sender].total_investments ++;
        my_investments[msg.sender].myinvestments[my_investments[msg.sender].total_investments] = total_investments;

        User_purchase[msg.sender].tokens += tokens;
        
        //_transfer(address(this), sender, tokens * (10 ** uint256(decimals())));        
        // emit Buy(sender, amount, tokens);
    }
    
    

    function claim (uint256 invest_id, uint256 _icoid) public returns(bool){
        require(investments[invest_id].status == true,"Invalid request.");
        require(investments[invest_id].myaddress == msg.sender,"Only owner can claim his token.");
        require(investments[invest_id].stakingTime >= block.timestamp,"You can claim after completing staking period.");
        ICOs[_icoid].stakingToken.transfer(msg.sender, investments[invest_id].tokens * (10 ** 18));
        investments[invest_id].status = false;        
        User_purchase[msg.sender].claimed += investments[invest_id].tokens;
    }

    function changeStatus(bool _status, uint256 _icoid) public onlyOwner returns (bool) {
        ICOs[_icoid].status = _status;
        //stakingFromToken.transferFrom(msg.sender, recipient, amount);
        return true;
    }

    function myPurchase(address myAddress) public view returns(uint256){
        return User_purchase[myAddress].tokens;
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
    function getNoOfICOs() public view returns(uint256){
            return total_ico;
    }

    function getInvestmentDetails(uint256 i_id) public view returns(uint256,address,uint256,bool,uint32){
        return (investments[i_id].ico, investments[i_id].myaddress, investments[i_id].tokens, investments[i_id].status, investments[i_id].stakingTime );
    }

    function getMyInvestments(address myad) public view returns(uint256, uint256[] memory){
        return (my_investments[myad].total_investments, my_investments[myad].myinvestments);
    }

    
    function getICODetails(uint256 _icoid) public view returns(IERC20,uint256,uint256,uint40,uint256,uint256,bool){
        return (ICOs[_icoid].stakingFromToken,ICOs[_icoid].ratePerToken,ICOs[_icoid].startTime,ICOs[_icoid].endTime,ICOs[_icoid].totalSupply,ICOs[_icoid].totalSale,ICOs[_icoid].status);
    }
    
    function getMinPurchase(uint256 _icoId)public view returns(uint256){
        return (ICOs[_icoId].minPurchase);
    }

}
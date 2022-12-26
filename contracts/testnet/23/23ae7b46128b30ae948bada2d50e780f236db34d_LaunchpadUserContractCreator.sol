/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
 

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Only Owner!");
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


interface IERC20 {
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burn(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount) external returns (bool);
}

interface ILaunchpadSale {
    function transferOwnership(address newOwner) external;
}

interface IUniswapV2Router {

     function WETH() external pure returns (address);

     function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface IUniswapV2Factory {
    function getPair(address token0, address token1) external view returns (address);
}



contract LaunchpadUserContractCreator is Owned , ReentrancyGuard{
 
    mapping(address => uint256[]) private userCreatedContractList;
    mapping(uint256 => address) public createdPools;

      
    uint256 createPrice = 0.01 ether;


    uint256 public poolID = 0;

    
    constructor() public {
        
    }


    function createPresale(
        address _token,
        uint256 _tokenDecimals,
        uint256 _tokenRatePerEth,
        uint256 _minEthLimit,
        uint256 _maxEthLimit,
        uint256 _StartDate,
        uint256 _EndDate,
        uint256 _HardCap,
        uint256 _Softcap,
        uint256[] memory _WestingWithdrawDate,
        uint256[] memory _WestingPercents,
        uint256 _poolPercent,
        uint256 _listRate,
        bool _isPrivate
    ) external payable nonReentrant {
        require(msg.value == createPrice,"Invalid fee");

        uint256[] memory _intArgs;
        
        _intArgs[0] = _tokenDecimals;
        _intArgs[1] = _tokenRatePerEth;
        _intArgs[2] = _minEthLimit;
        _intArgs[3] = _maxEthLimit;
        _intArgs[4] = _StartDate;
        _intArgs[5] = _EndDate;
        _intArgs[6] = _HardCap;
        _intArgs[7] = _Softcap;
        _intArgs[8] = _poolPercent;
        _intArgs[9] = _listRate;

        LaunchpadSale launchpad = new LaunchpadSale(
            _token,
            _intArgs,
            _WestingWithdrawDate,
            _WestingPercents,
            _isPrivate,
            msg.sender
        );

        createdPools[poolID] = address(launchpad);
        userCreatedContractList[msg.sender].push(poolID);

    } 
  
    function setCreatePrice(uint256 _price) external onlyOwner{
        createPrice = _price;
    }

    function getuserCreatedContractList(address _wallet) public view returns (uint256[] memory){
        return userCreatedContractList[_wallet];
    }

}


contract LaunchpadSale is Owned {
    using SafeMath for uint256;

    address private constant FACTORY = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;
    address private constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    
     
    //@dev ERC20 token address and decimals
    address public tokenAddress;
    uint256 public tokenDecimals;
    uint256 public totalSolded = 0;
    
    //@dev amount of tokens per ether 100 indicates 1 token per eth
    uint256 public tokenRatePerEth;
    //@dev decimal for tokenRatePerEth,
    //2 means if you want 100 tokens per eth then set the rate as 100 + number of rateDecimals i.e => 10000
    uint256 public rateDecimals = 0;
    
    //@dev max and min token buy limit per account
    uint256 public minEthLimit;
    uint256 public maxEthLimit;

    uint256 public StartDate;
    uint256 public EndDate;

    uint256 public HardCap;
    uint256 public Softcap;

    uint256 public poolPercent;
    uint256 public listRate;
    uint256 public commisionPercent = 4;

    struct VestingPlan{
       uint256 totalBalance;
       uint256 aviableBalance;
       uint256 timeStage;
    }

    struct TokenInfo{
        string tokenIconURL;
        string tokenWebsiteLink;
        string twitter;
        string telegram;
    }

    bool public isPrivate;
    mapping(address => bool) public Whitelist;

    mapping(address=>VestingPlan) public vestingBalance;

    // Withdraw Times
    uint256[] public WestingWithdrawDate;

    // Vesting Percents
    uint256[] public WestingPercents;
      
    mapping(address => uint256) public usersInvestments;

    address public recipient;
    
    constructor(
         address _token,
         uint256[] memory _intargs,
         uint256[] memory _WestingWithdrawDate,
         uint256[] memory _WestingPercents,
         bool _isPrivate,
         address creator
          
    ) public {
         tokenAddress = _token;
         tokenDecimals = _intargs[0];
         tokenRatePerEth = _intargs[1];
         minEthLimit = _intargs[2];
         maxEthLimit = _intargs[3];
         StartDate = _intargs[4];
         EndDate = _intargs[5];
         HardCap = _intargs[6];
         Softcap = _intargs[7];
         WestingWithdrawDate = _WestingWithdrawDate;
         WestingPercents = _WestingPercents;
         listRate = _intargs[8];
         isPrivate = _isPrivate;
         poolPercent = _intargs[9];

        require(poolPercent > 40 ,"Percentile must be greater than 45");
        ILaunchpadSale(address(this)).transferOwnership(creator);
      
    }



    function addForWhitelistAddress(address _address) external onlyOwner {
        require(isPrivate,"This pool is open to everyone");
        Whitelist[_address] = true;
    }

    function addForWhitelistAddressMulti(address[] memory _address) external onlyOwner {
        require(isPrivate,"This pool is open to everyone");
        for(uint256 a = 0; a < _address.length; a++){
            Whitelist[_address[a]] = true;
        }
    }

    function closePool() external onlyOwner{
        require(block.timestamp>EndDate,"The sale is not over.");

        uint256 Totalbalance = address(this).balance;
        uint256 liqBalance = (Totalbalance*poolPercent) / 100;
        uint256 commisionBalance = (Totalbalance*commisionPercent) / 100;
        uint256 availableBalance = Totalbalance.sub(liqBalance).sub(commisionBalance);

        uint256 tokenAmount = getTokensPerEthList(availableBalance);

        IERC20(tokenAddress).approve(ROUTER, getTokensPerEthList(availableBalance));

        IUniswapV2Router router = IUniswapV2Router(ROUTER);

        router.addLiquidityETH{value: liqBalance}(
            tokenAddress,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        address pair = IUniswapV2Factory(FACTORY).getPair(tokenAddress, router.WETH());
        uint PairBalance = IERC20(pair).balanceOf(address(this));
        IERC20(pair).transfer(owner, PairBalance);

        payable(owner).transfer(availableBalance);
        payable(recipient).transfer(commisionBalance);
    }

    function buyToken() public payable {
        require(
                usersInvestments[msg.sender].add(msg.value) <= maxEthLimit
                && usersInvestments[msg.sender].add(msg.value) >= minEthLimit,
                "Installment Invalid."
            );
        
        require(block.timestamp > StartDate && block.timestamp < EndDate , "Time Error");

        if(isPrivate){
            require(Whitelist[msg.sender],"You cannot participate in the private sale");
        }
        
        //@dev calculate the amount of tokens to transfer for the given eth
        uint256 tokenAmount = getTokensPerEth(msg.value);
        
        require(IERC20(tokenAddress).transfer(msg.sender, tokenAmount), "Insufficient balance of presale contract!");
        
        usersInvestments[msg.sender] = usersInvestments[msg.sender].add(msg.value);
        
        totalSolded = totalSolded + msg.value;
 
    }

    function withdrawToken() public {
        require(block.timestamp>EndDate,"You cannot withdraw because the sale period has not expired.");
        require(vestingBalance[msg.sender].aviableBalance > 0, "You do not have any tokens to withdraw.");
        require(vestingBalance[msg.sender].timeStage <= WestingWithdrawDate.length ,"All stages have been completed.");

        uint256 userAmount = vestingBalance[msg.sender].totalBalance;
        require(block.timestamp>WithdrawVestingTime(vestingBalance[msg.sender].timeStage),"It's not time to withdraw");
        uint256 withdrawAmount = (userAmount * WithdrawVestingPercent(vestingBalance[msg.sender].timeStage)) / 100;
        vestingBalance[msg.sender].aviableBalance = vestingBalance[msg.sender].aviableBalance - withdrawAmount;
        vestingBalance[msg.sender].timeStage = vestingBalance[msg.sender].timeStage + 1;
        if(vestingBalance[msg.sender].timeStage == WestingWithdrawDate.length){
            vestingBalance[msg.sender].aviableBalance = 0;
        }
        
        require(IERC20(tokenAddress).transfer(msg.sender, withdrawAmount), "Insufficient balance of this contract!");
    }

    function WithdrawVestingPercent(uint256 _stage) internal view returns(uint256){
        require(_stage>=0 && _stage<=WestingPercents.length,"Error");
           return WestingPercents[_stage];
    }

    function WithdrawVestingTime(uint256 _stage) public view returns(uint256){
        require(_stage>=0 && _stage<=WestingWithdrawDate.length,"Error");
        return WestingWithdrawDate[_stage];
    }
    
    function getTokensPerEth(uint256 amount) internal view returns(uint256) {
        return amount.mul(tokenRatePerEth).div(
            10**(uint256(18).sub(tokenDecimals).add(rateDecimals))
            );
    }

    function getTokensPerEthList(uint256 amount) internal view returns(uint256) {
        return amount.mul(tokenRatePerEth).div(
            10**(uint256(18).sub(listRate).add(rateDecimals))
            );
    }
    
    function burnUnsoldTokens() external onlyOwner {
        
        IERC20(tokenAddress).burn(IERC20(tokenAddress).balanceOf(address(this)));
    }
    
    function getUnsoldTokens() external onlyOwner {
        IERC20(tokenAddress).transfer(owner, IERC20(tokenAddress).balanceOf(address(this)));
    }
}
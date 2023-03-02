/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: UNLICENSED        
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
           
pragma solidity ^0.8.10;
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

pragma solidity ^0.8.10;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;
abstract contract Ownable is Context {   
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function ownable(address _newowner) internal{
        _transferOwnership(_newowner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IStake {
    function createStakePair(bytes32 _pairHash,address _token,uint _share ,uint ttTokenForReward) external;
    function stake(bytes32 _hash ,address _user ,uint _amount) external;
    function getStakeInfo(bytes32 _hash, address user) external view returns(uint,uint);
    function addLiqudity(bytes32 _pairHash,uint ttTokenForReward) external;
}

contract QuickSwap is Initializable, Ownable {

    struct Pair {
        address baseToken;
        address pairToken;
        uint totalLPSupply;
        mapping(address=>uint) owners;
        mapping(address=>uint) rewards;
        mapping(address=>uint) buyers;
        address[] ownersAddress;
        bool communitySell;
        uint price; 
        uint baseBalance;
        uint pairBalance;
        bool isStakingEnable;
        uint staking_share;
    }

    struct User {
        uint userId;
        address refferal;
    }

    enum Type {
        BUY,
        SELL
    }

    uint256 fee_numerator;
    uint256 fee_denominator;
    
    mapping(address=>mapping(address=>bytes32)) public pairHash;
    mapping(bytes32=>mapping(address=>bool)) public liquidityAdded;
    mapping(uint=>address) public idToAddress;
    mapping(address=>User) public users; 
    mapping(bytes32=>Pair) public quickpair;
    mapping(address=>bytes32[]) private liquidityByUser;

    mapping(bytes32 =>bool) private _lock;
    mapping(bytes32=>bool) private _buyEnable;
    mapping(bytes32=>bool) private _sellEnable;
    mapping(address=>bool) private _qouteEnable;
    bytes32[] private _getAllStakingPair; 

    address[] public qouteTokens;
    address public WETH;
    uint public lastUserId;
    IUniswapV2Router02 public pancakeRouter;
    IStake public staking;

    modifier lock(bytes32 _pairHash) {
        require(!_lock[_pairHash],"locked");
        _lock[_pairHash] = true;
        _;
        _lock[_pairHash] =false;
    }

    event QuickPair(address indexed baseToken, address indexed pairToken, address owner, uint price,bool communitySellEnable);
    event Registration(uint userId, address indexed _user, address referral);
    event AffiliateIncome(bytes32 _pairHash, address indexed _user, address _reciever ,uint _amount);
    event WithdrawAffiliate(address indexed _user, address _token ,uint _amount);
    event Buy(bytes32 _pairHash, address user, uint pairAmount, uint buyQnt, uint price, uint priceImpact,uint fee);
    event Sell(bytes32 _pairHash, address user, uint pairAmount, uint buyQnt, uint price, uint priceImpact,uint fee);

    function initialize(address _newowner,address[] calldata _qouteTokens, address _staking, address _pancakeRouter) external initializer {
        ownable(_newowner);
        fee_numerator = 3;
        fee_denominator = 1000;
        lastUserId=1;
        users[_newowner].userId =1;
        idToAddress[lastUserId] = _newowner;
        qouteTokens = _qouteTokens;
        for(uint i=0; i<_qouteTokens.length; i++) {
            _qouteEnable[_qouteTokens[i]]= true;
        }
        pancakeRouter = IUniswapV2Router02(_pancakeRouter);
        WETH = pancakeRouter.WETH();
        staking = IStake(_staking);
        lastUserId++;
    }

    function registration(address _user, address _refferal) internal{
        require(isUserExist(_refferal),"_refferal not exist!");
        users[_user].userId = lastUserId;
        users[_user].refferal = _refferal;
        emit Registration(lastUserId,_user, _refferal);
        lastUserId++;
    }
    
    function getPairHash(address _basetoken ,address pairToken) public pure returns (bytes32 _pairHash) {
        _pairHash = keccak256(abi.encode(keccak256("Pair(address baseToken,address pairToken)"), _basetoken , pairToken));   
    }

    function createPair(address _token ,address _pairtoken, uint _amount, uint _price,bool _communitySellEnable) external  {
        require(_qouteEnable[_pairtoken],"Invalid pairToken");
        require(!_qouteEnable[_token],"Invalid baseToken");
        require(IERC20(_token).allowance(msg.sender,address(this))>=_amount,"ERC20: allownace exceed");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        require(checkAnyPairExist(_token)==bytes32(0),"!!pair already exist!!");
        bytes32 _pairHash = getPairHash(_token,_pairtoken);
        pairHash[_token][_pairtoken] =_pairHash;
        pairHash[_pairtoken][_token] =_pairHash;
        quickpair[_pairHash].baseToken =_token;
        quickpair[_pairHash].pairToken =_pairtoken;
        quickpair[_pairHash].totalLPSupply += _amount;
        quickpair[_pairHash].baseBalance += _amount;

        if(!liquidityAdded[_pairHash][msg.sender]){
            liquidityByUser[msg.sender].push(_pairHash);
            liquidityAdded[_pairHash][msg.sender]=true;
        }

        _buyEnable[_pairHash] = true;
        _sellEnable[_pairHash] = true;
        quickpair[_pairHash].owners[msg.sender]=_amount;     
        quickpair[_pairHash].ownersAddress.push(msg.sender);   

        quickpair[_pairHash].price = _price;
        quickpair[_pairHash].communitySell = _communitySellEnable;
        emit QuickPair( _token, _pairtoken, msg.sender, _price, _communitySellEnable);
    }

    function createPairWithStaking(address _token ,address _pairtoken, uint _amount, uint _price,bool _communitySellEnable,uint _stakingShare) external onlyOwner  {
        require(_qouteEnable[_pairtoken],"Invalid pairToken");
        require(!_qouteEnable[_token],"Invalid baseToken");
        require(IERC20(_token).allowance(msg.sender,address(this))>=_amount+((_amount*_stakingShare)/100),"ERC20: allownace exceed");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount+((_amount*_stakingShare)/100));
        // transfer token to staking contract for apy
        IERC20(_token).transfer(address(staking),((_amount*_stakingShare)/100));
        
       require(checkAnyPairExist(_token)==bytes32(0),"!!pair already exist!!");
        bytes32 _pairHash = getPairHash(_token,_pairtoken);
        _getAllStakingPair.push(_pairHash);
        pairHash[_token][_pairtoken] =_pairHash;
        pairHash[_pairtoken][_token] =_pairHash;
        quickpair[_pairHash].baseToken =_token;
        quickpair[_pairHash].pairToken =_pairtoken;
        quickpair[_pairHash].totalLPSupply += _amount;
        quickpair[_pairHash].baseBalance += _amount;
        if(!liquidityAdded[_pairHash][msg.sender]){
            liquidityByUser[msg.sender].push(_pairHash);
            liquidityAdded[_pairHash][msg.sender]=true;
        }
        _buyEnable[_pairHash] = true;
        _sellEnable[_pairHash] = true;
        quickpair[_pairHash].owners[msg.sender]=_amount;     
        quickpair[_pairHash].ownersAddress.push(msg.sender);    
        quickpair[_pairHash].price = _price;
        quickpair[_pairHash].communitySell =_communitySellEnable;
        quickpair[_pairHash].isStakingEnable = true;
        quickpair[_pairHash].staking_share = _stakingShare;
        staking.createStakePair(_pairHash, _token, _stakingShare, ((_amount*_stakingShare)/100));
        emit QuickPair(_token,_pairtoken,msg.sender,_price,_communitySellEnable);
    }

    function addLiqudity(address _token , uint _amount) external payable {
        require(checkAnyPairExist(_token)!=bytes32(0),"!!pair not   exist!!");
        bytes32 _pairHash = checkAnyPairExist(_token);
        require(IERC20(_token).allowance(msg.sender,address(this))>=_amount+((_amount*quickpair[_pairHash].staking_share)/100),"ERC20: allownace exceed");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount+((_amount*quickpair[_pairHash].staking_share)/100));
        // transfer token to staking contract for apy
        if(quickpair[_pairHash].isStakingEnable){
            IERC20(_token).transfer(address(staking),((_amount*quickpair[_pairHash].staking_share)/100));
            staking.addLiqudity(_pairHash, ((_amount*quickpair[_pairHash].staking_share)/100));
        }
        
        if(!liquidityAdded[_pairHash][msg.sender]){
            liquidityByUser[msg.sender].push(_pairHash);
            liquidityAdded[_pairHash][msg.sender] = true;
        }
        quickpair[_pairHash].owners[msg.sender] += _amount;
        quickpair[_pairHash].totalLPSupply += _amount;
        quickpair[_pairHash].baseBalance += _amount;
       
    }
     
    function _buy(bytes32 _pairHash,uint _amount,address _refferal) internal lock(_pairHash) returns(uint,uint,uint) {
        require(buyEnable(_pairHash),"Buying off in this pair");
        if(!isUserExist(msg.sender)){
            registration(msg.sender, _refferal);
        }
        Pair storage pair = quickpair[_pairHash];
        uint256 _price = pair.price;
        uint fee = calculateFee(_amount);
        sendFee(_pairHash, (fee/2));
        uint qnt = ((_amount-fee)*10**IERC20(pair.baseToken).decimals())/_price;
        uint priceImpact = getPriceImpact(_pairHash,qnt);
        uint _priceImpactDebt = (qnt*priceImpact)/(100*10**IERC20(pair.baseToken).decimals());
        if(!pair.communitySell){
            quickpair[_pairHash].buyers[msg.sender] = qnt-_priceImpactDebt;
        }
        quickpair[_pairHash].pairBalance += _amount;
        quickpair[_pairHash].baseBalance -= (qnt-_priceImpactDebt);
        emit Buy(_pairHash,msg.sender,_amount,qnt,_price,priceImpact,fee);
        updatePrice(_pairHash, qnt-_priceImpactDebt,Type.BUY);
        return (qnt-_priceImpactDebt,_priceImpactDebt,fee);
    }

    function calculateBuy(bytes32 _pairHash,uint _amount) external view returns(uint,uint,uint) {
        Pair storage pair = quickpair[_pairHash];
        uint256 _price = pair.price;
        uint fee = calculateFee(_amount);
        uint qnt = ((_amount-fee)*10**IERC20(pair.baseToken).decimals())/_price;
        uint priceImpact = getPriceImpact(_pairHash,qnt);
        uint _priceImpactDebt = (qnt*priceImpact)/(100*10**IERC20(pair.baseToken).decimals());
        return (qnt-_priceImpactDebt,_priceImpactDebt,fee);
    }

    function calculateSell(bytes32 _pairHash,uint _amount) external view returns(uint,uint,uint){
        Pair storage pair = quickpair[_pairHash];
        uint256 _price = pair.price; //0.1
        uint priceImpact = getPriceImpact(_pairHash,_amount); //10
        uint _priceImpactDebt = (_amount*priceImpact)/(100*10**IERC20(pair.baseToken).decimals());   
        uint qnt = ((_amount-_priceImpactDebt)*_price)/(10**IERC20(pair.baseToken).decimals());
        uint fee = calculateFee(qnt);
        return (qnt-fee,_priceImpactDebt,fee);
    }

    // function getMinimumRecieve(address[] calldata path, uint _amountIn) external view returns(uint amountOut, uint fee, uint priceImapct) {
    //     bytes32 _pairHash = pairHash[path[0]][path[1]]; //pair exist
    //     bytes32 _neHash = checkAnyPairExist(path[0]);
    //     address _pairToken =  quickpair[_neHash].pairToken;

    //     if(_pairHash==bytes32(0)) {
    //         address[] memory npath = new address[](2);
    //         npath[0] = path[1];
    //         npath[1]= _pairToken;
    //         uint[] memory amounts = pancakeRouter.getAmountsOut(_amountIn,npath);
    //     } 
    // }

    function _sell(bytes32 _pairHash, uint _amount,address _refferal) internal lock(_pairHash) returns(uint,uint,uint) {
        require(sellEnable(_pairHash),"Selling off in this pair");

        if(!isUserExist(msg.sender)){
            registration(msg.sender, _refferal);
        }
        Pair storage pair = quickpair[_pairHash];
        uint256 _price = pair.price; //0.1
        uint priceImpact = getPriceImpact(_pairHash,_amount); //10
        uint _priceImpactDebt = (_amount*priceImpact)/(100*10**IERC20(pair.baseToken).decimals());   
        uint qnt = ((_amount-_priceImpactDebt)*_price)/(10**IERC20(pair.baseToken).decimals());
        uint fee = calculateFee(qnt);
        sendFee(_pairHash, (fee/2) );
        if(!pair.communitySell){
            quickpair[_pairHash].buyers[msg.sender] -= (_amount-_priceImpactDebt);
        }
        quickpair[_pairHash].baseBalance += (_amount-_priceImpactDebt);
        quickpair[_pairHash].pairBalance -= (qnt-fee);
  
        emit Sell(_pairHash,msg.sender,_amount,qnt,_price,priceImpact,fee);
        updatePrice(_pairHash, _amount-_priceImpactDebt,Type.SELL);
        return (qnt-fee,_priceImpactDebt,fee);
    }

    function buyTokensForTokensWithRefferal(address[] calldata path, uint _amount, address _refferal) external  {
        bytes32 _pairHash = pairHash[path[0]][path[1]];
        bytes32 _neHash = checkAnyPairExist(path[0]);
        require(_neHash!=bytes32(0),"Pair Not exist");
        require(WETH!=path[1],"Invalid Path");
        address _pairToken =  quickpair[_neHash].pairToken;
        Pair storage pair = quickpair[_neHash];
        require(IERC20(path[1]).allowance(msg.sender,address(this))>=_amount,"ERC20: allowance exceed");
        IERC20(path[1]).transferFrom(msg.sender,address(this),_amount);

        if(_pairHash==bytes32(0)) {
            address[] memory npath = new address[](2);
            npath[0] = path[1];
            npath[1]= _pairToken;
            IERC20(path[1]).approve(address(pancakeRouter),_amount);
            uint[] memory amounts = pancakeRouter.getAmountsOut(_amount,npath);
            if(WETH!=_pairToken) { 
                pancakeRouter.swapExactTokensForTokens(_amount,amounts[1],npath,address(this),(block.timestamp+3000));
            } else {
                pancakeRouter.swapExactTokensForETH(_amount,amounts[1],npath,msg.sender,(block.timestamp+3000));
            }
            (uint amtout,,) = _buy(_neHash,amounts[1],_refferal);
            if(pair.isStakingEnable){
                staking.stake(_neHash, msg.sender, amtout);
                _transfer(pair.baseToken, address(staking), amtout);
            } else{
                _transfer(pair.baseToken, msg.sender, amtout);
            }
        } else {
            (uint amtout,,) = _buy(_pairHash,_amount,_refferal);
            if(pair.isStakingEnable){
                staking.stake(_neHash, msg.sender, amtout);
                _transfer(pair.baseToken, address(staking), amtout);
            } else{
                _transfer(pair.baseToken, msg.sender, amtout);
            }
        }
       
    }    

    function sellTokensForTokensWithRefferal(address[] calldata path,uint _amount, address _refferal) external {
        require(WETH!=path[1],"Invalid Path");
        bytes32 _neHash = checkAnyPairExist(path[0]);
        Pair storage pair = quickpair[_neHash];
        require(IERC20(pair.baseToken).allowance(msg.sender,address(this))>=_amount,"ERC20: allowance exceed");
        IERC20(pair.baseToken).transferFrom(msg.sender,address(this),_amount);
        if(!pair.communitySell)
        require(getUserBuyAmt(_neHash,msg.sender)>(_amount),"only buyer can sell");
        (uint amtout,,) = _sell(_neHash, _amount,_refferal);
        if(path[1]==pair.pairToken){
            _transfer(pair.pairToken, msg.sender, amtout);
        } else {
            address[] memory npath = new address[](2);
            npath[0] = pair.pairToken;
            npath[1]=  path[1];
            IERC20(pair.pairToken).approve(address(pancakeRouter),amtout);
              if(WETH!=path[1]){
                if(WETH!=pair.pairToken) {
                    uint[] memory amounts = pancakeRouter.getAmountsOut(amtout,npath);
                    pancakeRouter.swapExactTokensForTokens(amtout,amounts[1],npath,msg.sender,(block.timestamp+3000));
                } else {
                    uint[] memory amounts = pancakeRouter.getAmountsOut(amtout,npath);
                    pancakeRouter.swapExactETHForTokens{value:amounts[1]}(amtout,npath,msg.sender,(block.timestamp+3000));
                }
            }
        }
    }

    function buyTokensForETHWithRefferal(address[] calldata path, uint _amount, address _refferal) external payable {
        bytes32 _pairHash = pairHash[path[0]][path[1]];
        bytes32 _neHash = checkAnyPairExist(path[0]);
        require(_neHash!=bytes32(0),"Pair Not exist");
        require(path[1]==WETH,"Invalid path");
        address _pairToken =  quickpair[_neHash].pairToken;
        Pair storage pair = quickpair[_neHash];
        require(msg.value>=_amount,"Invalid amount");
        if(_pairHash==bytes32(0)) {
            address[] memory npath = new address[](2);
            npath[0] = path[1];
            npath[1]= _pairToken;
            uint[] memory amounts = pancakeRouter.getAmountsOut(_amount,npath);
            pancakeRouter.swapExactETHForTokens{value:msg.value}(amounts[1],npath,address(this),(block.timestamp+3000));
            (uint amtout,,) = _buy(_neHash,amounts[1],_refferal);
            if(pair.isStakingEnable){
                    staking.stake(_neHash, msg.sender, amtout);
                _transfer(pair.baseToken, address(staking), amtout);
            } else{
                _transfer(pair.baseToken, msg.sender, amtout);
            }
     

        } else {
            (uint amtout,,) = _buy(_pairHash, _amount,_refferal);
            if(pair.isStakingEnable){
                staking.stake(_neHash, msg.sender, amtout);
                _transfer(pair.baseToken, address(staking), amtout);
            } else{
                _transfer(pair.baseToken, msg.sender, amtout);
            }
        }
    }

    function sellTokensForETHWithRefferal(address[] calldata path, uint _amount,address _refferal) external {
        bytes32 _neHash = checkAnyPairExist(path[0]);
        Pair storage pair = quickpair[_neHash];
        require(IERC20(pair.baseToken).allowance(msg.sender,address(this))>=_amount,"ERC20: allowance exceed");
        IERC20(pair.baseToken).transferFrom(msg.sender,address(this),_amount);
        if(!pair.communitySell)
        require(getUserBuyAmt(_neHash,msg.sender)>(_amount),"only buyer can sell");
        (uint amtout,,) = _sell(_neHash, _amount,_refferal);
        if(path[1]==pair.pairToken){
            _transfer(pair.pairToken, msg.sender, amtout);
        } else {
            address[] memory npath = new address[](2);
            npath[0] = pair.pairToken;
            npath[1]=  path[1];
            IERC20(pair.pairToken).approve(address(pancakeRouter),amtout);
            if(WETH==path[1]||WETH==pair.pairToken) {
                uint[] memory amounts = pancakeRouter.getAmountsOut(amtout,npath);
                pancakeRouter.swapExactTokensForETH(amtout,amounts[1],npath,msg.sender,(block.timestamp+3000));
            }
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts){
         require(IERC20(path[0]).allowance(msg.sender,address(this))>=amountIn,"ERC20: allowance exceed");
        IERC20(path[0]).transferFrom(msg.sender,address(this),amountIn);
          IERC20(path[0]).approve(address(pancakeRouter),amountIn);
            return pancakeRouter.swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts){
         require(IERC20(path[0]).allowance(msg.sender,address(this))>=amountIn,"ERC20: allowance exceed");
        IERC20(path[0]).transferFrom(msg.sender,address(this),amountIn);
          IERC20(path[0]).approve(address(pancakeRouter),amountIn);
        return pancakeRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts){
        return pancakeRouter.swapExactETHForTokens{value:msg.value}(amountOutMin, path, to, deadline);
    }

    function updatePrice(bytes32 _hash,uint _amount ,Type _type) internal  {
        uint decimals = IERC20(quickpair[_hash].pairToken).decimals();
        uint256 percentSell = getSellPercent(_hash,_amount);
        if(_type==Type.BUY)  
            quickpair[_hash].price = (quickpair[_hash].price+((quickpair[_hash].price*percentSell)/(100*10**decimals)));
        else 
            quickpair[_hash].price = (quickpair[_hash].price-((quickpair[_hash].price*percentSell)/(100*10**decimals)));
    }

    function getSellPercent(bytes32 _hash,uint _amount) public view returns (uint256) {
        uint256 percentSell;
        uint decimals = IERC20(quickpair[_hash].pairToken).decimals();
        if (_amount != 0) percentSell = ((_amount*100)*(10**decimals))/(quickpair[_hash].baseBalance);
        return percentSell;
    }

    function getPriceImpact(bytes32 _hash,uint _amount) public view returns(uint256) {
        uint decimals = IERC20(quickpair[_hash].baseToken).decimals();
        uint256 ttlLiqudity = quickpair[_hash].baseBalance;
        uint percent= ((_amount*100)*(10**decimals))/ttlLiqudity;
        return percent;
    } 
    
    function calculateFee(uint _amount) public view returns(uint) {
        return (_amount*fee_numerator)/fee_denominator;
    }   

    function getLiqudityByUser(bytes32 _hash, address user) external view returns(uint) {
       return quickpair[_hash].owners[user]; 
    }
    
    function getRewardByUser(bytes32 _hash, address user) external view returns(uint) {
        return quickpair[_hash].rewards[user]; 
    }

    function setFees(
        uint256 _fee_numerator,
        uint256 _fee_denominator
    ) external  onlyOwner{
       fee_numerator = _fee_numerator;
       fee_denominator = _fee_denominator;
    }

    function getFees() external view returns(uint fee_numerator_, uint fee_denominator_){
        fee_numerator_ = fee_numerator;
        fee_denominator_ = fee_denominator;
    }  

    function sendFee(bytes32 _pairHash, uint _amount ) internal {
        uint ttlLqd = quickpair[_pairHash].totalLPSupply;
        for(uint i=0;i<quickpair[_pairHash].ownersAddress.length;i++) {
            address _owner= quickpair[_pairHash].ownersAddress[i];
            if(quickpair[_pairHash].owners[_owner]>0) {
                uint percent = (quickpair[_pairHash].owners[_owner]*100)/ttlLqd;
                quickpair[_pairHash].rewards[_owner]=(_amount*percent)/100;
            }
        }
    }

    function removeLiqudity(bytes32 _pairHash,uint _amount) external  {
        uint ttlToken = IERC20(quickpair[_pairHash].baseToken).balanceOf(address(this));
        require(quickpair[_pairHash].owners[msg.sender]>=_amount,"QuickBuy: remove liqudity morethan add liqudity");
        if(ttlToken>_amount){
            _transfer(quickpair[_pairHash].baseToken,msg.sender, _amount);
            _transfer(quickpair[_pairHash].pairToken,msg.sender, quickpair[_pairHash].rewards[msg.sender]);
            quickpair[_pairHash].owners[msg.sender]-=_amount;
            quickpair[_pairHash].rewards[msg.sender]=0;
        } else {
            _transfer(quickpair[_pairHash].pairToken,msg.sender, quickpair[_pairHash].rewards[msg.sender]);
            quickpair[_pairHash].rewards[msg.sender]=0;
        }
    }

    function _transfer(address _token, address _to , uint _amount) internal  {
        if(WETH==_token)
            payable(_to).transfer(_amount);
        else 
            IERC20(_token).transfer(_to, _amount);
    }

    function isUserExist(address _user) public view returns(bool) {
       return  (users[_user].userId!=0);
    }

    function getUserBuyAmt(bytes32 _pairHash, address _user) public view returns(uint){
        return quickpair[_pairHash].buyers[_user];
    }

    function getAllliquidityByUser(address user) external view returns (bytes32[] memory) {
        return liquidityByUser[user];
    }

    function setPairBuyStatus(bytes32 _pairHash,bool _status) external onlyOwner {
        _buyEnable[_pairHash] =_status;
    }

    function setPairSellStatus (bytes32 _pairHash,bool _status) external onlyOwner {
        _sellEnable[_pairHash] =_status;
    }

    function buyEnable(bytes32 _pairHash) public view returns(bool) {
        return _buyEnable[_pairHash];
    }
        
    function sellEnable(bytes32 _pairHash) public view returns(bool) {
        return _sellEnable[_pairHash];
    }

    function getParentbyUser(address user) external view returns(address) {
        return users[user].refferal;
    }
    
    function checkAnyPairExist(address _token) public view returns (bytes32 _pairHash ) {
        for(uint i = 0; i<qouteTokens.length; i++) {
            _pairHash = pairHash[_token][qouteTokens[i]];
            if(_pairHash!=bytes32(0)) break;
        }
    }

    function getAmountOut(address[] calldata path, uint amount) external view returns(uint[] memory) {
        return pancakeRouter.getAmountsOut(amount,path);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external view returns (uint amountOut) {
        return pancakeRouter.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external view returns (uint amountIn) {
        return pancakeRouter.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts) {
        return pancakeRouter.getAmountsOut(amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts) {
        return pancakeRouter.getAmountsIn(amountOut, path);
    }

    function changePancakeRouter(address _newRouter) external  onlyOwner {
          pancakeRouter = IUniswapV2Router02(_newRouter);
    }

    function changeStakingContract(address _newStaking) external  onlyOwner {
          staking = IStake(_newStaking);
    }
     function getLiqudityFromRouter(address[] calldata path) external  view  returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast,address token0, address token1) {
        address _pair =  IUniswapV2Factory(pancakeRouter.factory()).getPair(path[0],path[1]);
        (reserve0,reserve1,blockTimestampLast)= IUniswapV2Pair(_pair).getReserves();
        token0 = IUniswapV2Pair(_pair).token0();
        token1 = IUniswapV2Pair(_pair).token1();
    }
}
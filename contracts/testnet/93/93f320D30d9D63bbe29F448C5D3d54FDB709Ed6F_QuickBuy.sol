pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
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

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED
interface IExchangeFactory {
    function getFees() external view returns(uint taker_fee_numerator_, uint taker_fee_denominator_, uint maker_fee_numerator_, uint maker_fee_denominator_);
    function feeTo() external view returns (address);
    function weth() external view returns (address);
    function listingEnable(address) external view returns (bool);
}

// SPDX-License-Identifier: Unlicense
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
abstract contract Initializable {

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

pragma solidity ^0.8.0;
import "./library/Context.sol";
import "./library/Initializable.sol";
import "./interface/IERC20.sol";
import "./interface/IExchangeFactory.sol";

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

contract QuickBuy is Initializable,Ownable {

    struct Pair {
        address baseToken;
        address pairToken;
        uint totalLiqudity;
        mapping(address=>uint) owners;
        mapping(address=>uint) rewards;
        address[] ownersAddress;
        mapping(address=>uint) buyers;
        uint basePrice; 
        uint totalSell;
    }

    uint256 fee_numerator;
    uint256 fee_denominator;

    
    mapping(address=>mapping(address=>bool)) public isPairExist;
    mapping(address=>mapping(address=>bytes32)) public pairHash;
    mapping(bytes32=>Pair) private quickpair;
    address public factory;
    mapping(bytes32 =>bool) private _lock;

    modifier lock(bytes32 _pairHash){
        require(!_lock[_pairHash],"locked");
        _lock[_pairHash] = true;
        _;
        _lock[_pairHash] =false;
    }

    event QuickPair(address indexed baseToken, address indexed pairToken, address owner, uint price);
    event Buy(bytes32 _pairHash, address user, uint pairAmount, uint buyQnt, uint price, uint priceImpact,uint fee);
    event Sell(bytes32 _pairHash, address user, uint pairAmount, uint buyQnt, uint price, uint priceImpact,uint fee);

    function initialize(address _newowner,address _factory) external initializer {
        ownable(_newowner);
        factory =_factory;
        fee_numerator = 3;
        fee_denominator = 1000;
    }

    function getPairHash(address _basetoken ,address pairToken) public pure returns (bytes32 _pairHash) {
        _pairHash = keccak256(abi.encode(keccak256("Pair(address baseToken,address pairToken)"), _basetoken , pairToken));   
    }

    function createPair(address _token ,address _pairtoken, uint _amount, uint _price) external  {
        require(IExchangeFactory(factory).listingEnable(_pairtoken),"Invalid pairToken");
        require(IERC20(_token).allowance(msg.sender,address(this))>=_amount,"ERC20: allownace exceed");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        require(!isPairExist[_token][_pairtoken],"!!pair already exist!!");
        isPairExist[_token][_pairtoken] = true;
        isPairExist[_token][_pairtoken] = true; 
        bytes32 _pairHash = getPairHash(_token,_pairtoken);
        pairHash[_token][_pairtoken] =_pairHash;
        quickpair[_pairHash].baseToken =_token;
        quickpair[_pairHash].pairToken =_pairtoken;
        quickpair[_pairHash].totalLiqudity += _amount;
        quickpair[_pairHash].owners[msg.sender]=_amount;     
        quickpair[_pairHash].ownersAddress.push(msg.sender);    
        quickpair[_pairHash].basePrice = _price;
        emit QuickPair(_token,_pairtoken,msg.sender,_price);
    }

    function addLiqudity(address _token ,address _pairtoken, uint _amount) external payable {
        require(IERC20(_token).allowance(msg.sender,address(this))>_amount,"ERC20: allownace exceed");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        require(isPairExist[_token][_pairtoken],"!!pair already exist!!");
        bytes32 _pairHash = getPairHash(_token,_pairtoken);
        if(quickpair[_pairHash].owners[msg.sender]==0){
            quickpair[_pairHash].ownersAddress.push(msg.sender);
        }
        quickpair[_pairHash].owners[msg.sender]=_amount;
        quickpair[_pairHash].totalLiqudity+=_amount;
    }
         
    function buyTokensForTokens(bytes32 _pairHash, uint _amount) external lock(_pairHash) {
        Pair storage pair = quickpair[_pairHash];
        require(IERC20(pair.pairToken).allowance(msg.sender,address(this))>=_amount,"ERC20: allowance exceed");
        IERC20(pair.pairToken).transferFrom(msg.sender,address(this),_amount);
        uint256 _price = currentPrice(_pairHash);
        uint fee = calculateFee(_amount);
        sendFee(_pairHash, (fee/2) );
        uint qnt = ((_amount-fee)*10**IERC20(pair.baseToken).decimals())/_price;
        uint priceImpact = getPriceImpact(_pairHash,qnt);
        uint _priceImpactDebt = (qnt*priceImpact)/(100*10**IERC20(pair.baseToken).decimals());
        require(pair.totalLiqudity-pair.totalSell>=qnt-_priceImpactDebt,"Low liqudity");
        quickpair[_pairHash].buyers[msg.sender] = qnt-_priceImpactDebt;
        quickpair[_pairHash].totalSell+=qnt-_priceImpactDebt;
        IERC20(pair.baseToken).transfer(msg.sender,qnt-_priceImpactDebt);
        emit Buy(_pairHash,msg.sender,_amount,qnt,_price,priceImpact,fee);
    }           

    function sellTokensForTokens(bytes32 _pairHash, uint _amount) external lock(_pairHash){
        Pair storage pair = quickpair[_pairHash];
        require(IERC20(pair.baseToken).allowance(msg.sender,address(this))>=_amount,"ERC20: allowance exceed");
        IERC20(pair.baseToken).transferFrom(msg.sender,address(this),_amount);
        uint256 _price = currentPrice(_pairHash);
        uint _dec = IERC20(pair.baseToken).decimals();
        uint priceImpact = getPriceImpact(_pairHash,_amount);
        uint _priceImpactDebt = (_amount*priceImpact)/(100*10**_dec);
        uint qnt = ((_amount-_priceImpactDebt)*_price)/(10**_dec);
        uint fee = calculateFee(qnt);
        sendFee(_pairHash, (fee/2) );
        require(quickpair[_pairHash].buyers[msg.sender]>=(_amount-_priceImpactDebt),"only buyer can sell");
        require(pair.totalSell+(_amount-_priceImpactDebt)<=pair.totalLiqudity,"Low liqudity");
        quickpair[_pairHash].buyers[msg.sender] -= (_amount-_priceImpactDebt);
        quickpair[_pairHash].totalSell -= (_amount-_priceImpactDebt);
        IERC20(pair.pairToken).transfer(msg.sender, qnt-fee);
        emit Sell(_pairHash,msg.sender,_amount,qnt,_price,priceImpact,fee); 
    }

    function buyTokensForETH(bytes32 _pairHash, uint _amount) external payable lock(_pairHash){
        Pair storage pair = quickpair[_pairHash];
        require(msg.value>=_amount,"Invalid amount");
        uint256 _price = currentPrice(_pairHash);
        uint fee = calculateFee(_amount);
        sendFee(_pairHash, (fee/2) );
        uint qnt = ((_amount-fee)/_price)*(10**IERC20(pair.baseToken).decimals());
        uint priceImpact = getPriceImpact(_pairHash,qnt);
        uint _priceImpactDebt = (qnt*priceImpact)/(100*10**IERC20(pair.baseToken).decimals());
        require(pair.totalLiqudity-pair.totalSell>=qnt-_priceImpactDebt,"Low liqudity");
        quickpair[_pairHash].buyers[msg.sender] = qnt-_priceImpactDebt;
        quickpair[_pairHash].totalSell+=qnt-_priceImpactDebt;
        IERC20(pair.baseToken).transfer(msg.sender,qnt-_priceImpactDebt);
        emit Buy(_pairHash,msg.sender,_amount,qnt,_price,priceImpact,fee);

    }

    function sellTokensForETH(bytes32 _pairHash, uint _amount) external lock(_pairHash){
        Pair storage pair = quickpair[_pairHash];
        require(IERC20(pair.baseToken).allowance(msg.sender,address(this))>=_amount,"ERC20: allowance exceed");
        IERC20(pair.baseToken).transferFrom(msg.sender,address(this),_amount);
        uint256 _price = currentPrice(_pairHash);
        uint priceImpact = getPriceImpact(_pairHash,_amount);
        uint _priceImpactDebt = (_amount*priceImpact)/(100*10**IERC20(pair.baseToken).decimals());
        uint qnt = ((_amount-_priceImpactDebt)*_price)/(10**IERC20(pair.baseToken).decimals());
        uint fee = calculateFee(qnt);
        sendFee(_pairHash, (fee/2) );
        require(quickpair[_pairHash].buyers[msg.sender]>=(_amount-_priceImpactDebt),"only buyer can sell");
        require(pair.totalSell+_amount<=pair.totalLiqudity,"Low liqudity");
        quickpair[_pairHash].buyers[msg.sender] -=( _amount-_priceImpactDebt);
        quickpair[_pairHash].totalSell-=(_amount-_priceImpactDebt);
        payable(msg.sender).transfer(qnt-fee);
        emit Sell(_pairHash,msg.sender,_amount,qnt,_price,priceImpact,fee);
    }

    function currentPrice(bytes32 _hash) public view returns (uint256) {
        uint decimals = IERC20(quickpair[_hash].pairToken).decimals();
        uint256 percentSell = getSellPercent(_hash);
        // console.log("percent : %s , basePrice: %s",percentSell,quickpair[_hash].basePrice);
        return (quickpair[_hash].basePrice+((quickpair[_hash].basePrice*percentSell)/(100*10**decimals)));
    }

    function getSellPercent(bytes32 _hash) public view returns (uint256) {
        uint256 ttlTokenRealsed = quickpair[_hash].totalSell;
        uint256 percentSell;
        uint decimals = IERC20(quickpair[_hash].pairToken).decimals();
        if (ttlTokenRealsed != 0) percentSell = ((ttlTokenRealsed*100)*(10**decimals))/(quickpair[_hash].totalLiqudity);
        return percentSell;
    }

    function getPriceImpact(bytes32 _hash,uint _amount) public view returns(uint256) {
        uint decimals = IERC20(quickpair[_hash].baseToken).decimals();
        uint256 ttlLiqudity = quickpair[_hash].totalLiqudity;
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
        uint ttlLqd = quickpair[_pairHash].totalLiqudity;
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
        address weth = IExchangeFactory(factory).weth();
        if(weth==_token)
            payable(_to).transfer(_amount);
        else 
            IERC20(_token).transfer(_to, _amount);
    }
}
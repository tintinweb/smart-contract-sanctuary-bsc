/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "add err");
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "sub err");
    return a - b;
  }

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(a == 0 || c / a == b, "mul err");
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "div 0 err");
    uint256 c = a / b;
    require(a == b * c + a % b, "div err"); // There is no case in which this doesn't hold
    return c;
  }

}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
interface ERC20Basic {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable {
    address private _owner;

    // event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = msg.sender;
        // emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    // function renounceOwnership() public onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        // emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// pragma solidity >=0.5.0;

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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WHT() external pure returns (address);

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

contract TxRule is Ownable{
    using SafeMath for uint256;

    address public _systemAddress1;
    address public _systemAddress2;
    address public _systemAddress3;
    address public adminContract;

    mapping(address => bool) public txWhiteList;
    address[] public noNeedRedUsers;
    mapping(address => bool) public noNeedRedUsersDic;
    bool public needGas = true; 
    bool public needSendRed = true;
    uint256 public allTotalGas = 0;
    uint256 public sendGasMin = 1; //1000 * (10**18);
    // uint256 public haveRedMin = 10000 * (10**18);
    uint256 public haveRedMin = 10000 * (10**18);
    uint256 public haveRedAllAmount = 0;
    uint256[] public gasRedRatioList = [30,20,70,5,10,5,10]; // /1000
    bool public swapStartOn = false; 
    
    SwapHelp swapHelp;
    address public swapHelpAddress;
    
    function setSwapHelp(address _address) external onlyOwner {
        swapHelpAddress = _address;
        swapHelp = SwapHelp(_address);
        txWhiteList[_address] = true;
        noNeedRedUsers.push(_address);
        noNeedRedUsersDic[_address] = true;
    }
    // function updateSendGasMin(uint256 _value) external onlyOwner {
    //     require(_value>0, "_value is 0");
    //     sendGasMin = _value;
    // }
    function updateHaveRedMin(uint256 _value) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        require(_value>0, "_value is 0");
        haveRedMin = _value;
    }
    function needGasOnOff(bool _bo) external onlyOwner {
        needGas = _bo;
    }
    function needSendRedOnOff(bool _bo) external onlyOwner {
        needSendRed = _bo;
    }
    function addTxWhiteList(address _address) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        txWhiteList[_address] = true;
    }
    function subTxWhiteList(address _address) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        delete txWhiteList[_address];
    }
    function addNoNeedRedUsers(address _address) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        noNeedRedUsers.push(_address);
        noNeedRedUsersDic[_address] = true;
    }
    function subNoNeedRedUsers(uint256 _index) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        delete noNeedRedUsersDic[noNeedRedUsers[_index]];
        delete noNeedRedUsers[_index];
    }
    function updateSystemAddress1(address _address) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        _systemAddress1 = _address;
    }
    function updateSystemAddress2(address _address) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        _systemAddress2 = _address;
    }
    function updateSystemAddress3(address _address) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        _systemAddress3 = _address;
    }
    function updateGasRatioList(uint256[] memory _values) public {
        require(msg.sender == adminContract || isOwner(), "account error");
        require(_values.length == 7, "_values len is 7");
        uint256 gasRedRatioAll = 0;
        for (uint i=0; i<_values.length; i++) {
            gasRedRatioAll += _values[i];
        }
        require(gasRedRatioAll > 0 && gasRedRatioAll < 1000, "_values sum error");
        gasRedRatioList= _values;
    }
    
    function updateAdminContract(address _address) external onlyOwner {
        adminContract = _address;
    }
    function offSwapStartOn() external onlyOwner {
        swapStartOn = false;
    }
  
    /**
     * 分红 
    */ 
    uint256 public allTotalReward = 0;  
    uint256 public lastTotalReward = 0;
    uint256 public totalAccSushi = 0;
    uint256 public allTotalRewardLp = 0;  
    uint256 public lastTotalRewardLp = 0;
    uint256 public totalAccSushiLp = 0;
    struct UserStruct {
        uint256 curReward;
        uint256 accSushi;
        uint256 accSushiLp;
        uint256 exUpdateAccSushi;
    }
    // 地址=>用户信息
    mapping(address => UserStruct) public users;
    
    /**
     * swap 
    */ 
    uint256 public exUpdateAccSushi = 0;
    uint256 public exUpdateAccSushiLp = 0;
    address[] public swapPath;
    // wht 0x5545153ccfca01fbd7dd11c0b23ba694d9509a6f 
    // address public exToken = 0xE55b3Fb96Bb83fBd483170eaecc39A8159cB253A; // nftbet
    // address public exBase = 0xa71EdC38d189767582C38A3145b5873052c3e47a; // usdt
    // address usdt = 0xa71EdC38d189767582C38A3145b5873052c3e47a;
    // address swap = 0xED7d5F38C79115ca12fe6C0041abb22F0A06C300; // heco
    address public exToken = 0x2859e4544C4bB03966803b044A93563Bd2D0DD4D; // shib
    address public exBase = 0x55d398326f99059fF775485246999027B3197955; // usdt
    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    address swap = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // bsc
    ERC20Basic cakeToken = ERC20Basic(exToken);
    
    // address uniswapV2Pair = address(0x0);
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    ERC20Basic public lpTokenContract;
    constructor () { 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(swap); 
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdt); //getPair, createPair
        uniswapV2Router = _uniswapV2Router;
        lpTokenContract = ERC20Basic(uniswapV2Pair);
        
        swapPath = new address[](3);
        swapPath[0] = address(this);
        swapPath[1] = usdt;
        swapPath[2] = exToken;
    }
    function updateExAndBaseToken(address _exToken, address _exBase) external onlyOwner {
        exToken = _exToken;
        exBase = _exBase;
        exUpdateAccSushi = totalAccSushi;
        lastTotalReward = allTotalReward;
        cakeToken.transfer(_systemAddress1, cakeToken.balanceOf(address(this)));
        cakeToken = ERC20Basic(exToken);

        if (_exBase == usdt) {
        swapPath = new address[](3);
        swapPath[0] = address(this);
        swapPath[1] = usdt;
        swapPath[2] = exToken;
        } else {
        swapPath = new address[](4);
        swapPath[0] = address(this);
        swapPath[1] = usdt;
        swapPath[2] = exBase;
        swapPath[3] = exToken;
        }
    }
}

interface SwapHelp  {
    function buySwap() external;
}
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract StandardToken is ERC20Basic,TxRule {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 _totalSupply;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
    if(msg.data.length < size + 4) {
      revert();
    }
    _;
  }
    
    function balanceRedOf(address _user) public view returns (uint256) {
        if (noNeedRedUsersDic[_user]) {return 0;}    
        UserStruct memory user = users[_user];
        
        uint256 accSushi = user.accSushi;
        uint256 accSushiLp = user.accSushiLp;
        if (user.exUpdateAccSushi < exUpdateAccSushi) {
            accSushi = exUpdateAccSushi;
            accSushiLp = exUpdateAccSushiLp;
        }       
    
        uint256 _nowSushi = totalAccSushi.add(allTotalReward.sub(lastTotalReward).mul(_totalSupply).div(haveRedAllAmount));
        // uint256 _userRed = balanceOf(_user).mul(_nowSushi.sub(user.accSushi)).div(_totalSupply);
        uint256 _userRed = 0;
        if (balanceOf(_user) >= haveRedMin) {
            _userRed = balanceOf(_user).mul(_nowSushi.sub(accSushi)).div(_totalSupply);
        }

        uint256 _nowSushiLp = totalAccSushiLp.add(allTotalRewardLp.sub(lastTotalRewardLp).mul(_totalSupply).div(totalValidBalanceLp()));
        uint256 _userRedLp = lpTokenContract.balanceOf(_user).mul(_nowSushiLp.sub(accSushiLp)).div(_totalSupply);
        return _userRed + _userRedLp;
    }

    function totalValidBalanceLp() public view returns (uint256) {
        uint256 amount = lpTokenContract.totalSupply()+1;
        for (uint256 i=0; i < noNeedRedUsers.length; i++) {
            if (noNeedRedUsers[i] != address(0x0)) {
                uint256 balance = lpTokenContract.balanceOf(noNeedRedUsers[i]);
                amount = amount.sub(balance);
            }
        }  
        return amount.sub(lpTokenContract.balanceOf(address(0x0)));
    }
    
    function handleSendRed(address _user) private{
        if (noNeedRedUsersDic[_user]) {return;}
        UserStruct storage user = users[_user];
        if (user.exUpdateAccSushi < exUpdateAccSushi) {
            user.exUpdateAccSushi = exUpdateAccSushi;
            user.accSushi = exUpdateAccSushi;
            user.accSushiLp = exUpdateAccSushiLp;
        }
        uint256 _totalRed = allTotalReward.sub(lastTotalReward);
        uint256 _nowSushi = totalAccSushi.add(_totalRed.mul(_totalSupply).div(haveRedAllAmount));
        uint256 _userRed = 0;
        if (balanceOf(_user) >= haveRedMin) {
            _userRed = balanceOf(_user).mul(_nowSushi.sub(user.accSushi)).div(_totalSupply);
        }
        
        user.accSushi = _nowSushi;        
        totalAccSushi = _nowSushi;
        lastTotalReward = allTotalReward;

        handleSendRedLp(_user, _userRed);
    }
    function handleSendRedLp(address _user, uint256 _userRed0) private{
        UserStruct storage user = users[_user];
        
        uint256 _totalRed = allTotalRewardLp.sub(lastTotalRewardLp);
        uint256 _nowSushi = totalAccSushiLp.add(_totalRed.mul(_totalSupply).div(totalValidBalanceLp()));
        uint256 _userRed = lpTokenContract.balanceOf(_user).mul(_nowSushi.sub(user.accSushiLp)).div(_totalSupply);
        _userRed = _userRed+_userRed0;
        if (_userRed > 0) {
            cakeToken.transfer(_user, _userRed);
            user.curReward = user.curReward.add(_userRed);
        }
        
        user.accSushiLp = _nowSushi;
        totalAccSushiLp = _nowSushi;
        lastTotalRewardLp = allTotalRewardLp;
    }

    uint256 public systemAmount2 = 0;
    uint256 public lastSystemAmount2 = 0;
    uint256 public lastAllTotalGas = 0;
    
    function swapTokensForCake(uint256 tokenAmount, address receiveAddress) private {
        // approve(address(uniswapV2Router), tokenAmount);
        allowed[address(this)][address(uniswapV2Router)] = tokenAmount;
        emit Approval(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            swapPath,
            receiveAddress,
            block.timestamp
        );
    }
    function swapTokensToUsdt(uint256 tokenAmount, address receiveAddress) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        // approve(address(uniswapV2Router), tokenAmount);
        allowed[address(this)][address(uniswapV2Router)] = tokenAmount;
        emit Approval(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            receiveAddress,
            block.timestamp
        );
    }
    function countGasRedRatioAll() public view returns(uint256){
        uint256 gasRedRatioAll = 0;
        for (uint256 i=0; i < gasRedRatioList.length; i++) {
            gasRedRatioAll += gasRedRatioList[i];
        }
        return gasRedRatioAll;
    }
    function handleTrasfer() public {
        require(msg.sender == adminContract || isOwner(), "account error");
        uint256 subAmount = allTotalGas.sub(lastAllTotalGas);
        if (subAmount > sendGasMin) {
            lastAllTotalGas = allTotalGas;
            uint256 gasRatioAll = countGasRedRatioAll()-gasRedRatioList[4];
            
            inTtransfer(address(this), _systemAddress1, subAmount.mul(gasRedRatioList[1]).div(gasRatioAll));
            swapTokensToUsdt(subAmount.mul(gasRedRatioList[5]).div(gasRatioAll), _systemAddress2);
            swapTokensToUsdt(subAmount.mul(gasRedRatioList[6]).div(gasRatioAll), _systemAddress3);
    
            inTtransfer(address(this), swapHelpAddress, subAmount.mul(gasRedRatioList[3]).div(gasRatioAll));
            swapHelp.buySwap();
            
            uint256 initBalance = cakeToken.balanceOf(address(this));
            swapTokensForCake(subAmount.mul(gasRedRatioList[0]+gasRedRatioList[2]).div(gasRatioAll), address(this));
            uint256 newBalance = cakeToken.balanceOf(address(this)).sub(initBalance);
            uint256 tokenRedAmount = newBalance.mul(gasRedRatioList[0]).div(gasRedRatioList[0]+gasRedRatioList[2]);
            allTotalReward = allTotalReward.add(tokenRedAmount);
            allTotalRewardLp = allTotalRewardLp.add(newBalance.sub(tokenRedAmount));
        }
        if (systemAmount2.sub(lastSystemAmount2) > sendGasMin.div(10)) {
            swapTokensForCake(systemAmount2.sub(lastSystemAmount2), _systemAddress3);
            lastSystemAmount2 = systemAmount2;
        }
    }
    function handleSubGasBalance(address _user, address _to, uint256 _value) private{
        uint256 _gas = _value.mul(countGasRedRatioAll()).div(1000);
        uint256 peerGas = _value.mul(1).div(1000);
        allTotalGas = allTotalGas.add(_gas).sub(gasRedRatioList[4].mul(peerGas));
        if (_user != _to) {// sell
            _gas += peerGas.mul(10);
            systemAmount2 = systemAmount2.add(peerGas.mul(10));
        }
        inTtransfer(_to, address(this), _gas);
        inTtransfer(address(this), address(0x01), gasRedRatioList[4].mul(peerGas));
    }
    function inTtransfer(address _from, address _to, uint256 _value) private {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }
    
    function _transfer(address _from, address _to, uint256 _value) private {
        require(_value <= balances[_from], "_from balance low");
        if (swapStartOn && (_from == uniswapV2Pair || _to == uniswapV2Pair)) {
            if (_from == uniswapV2Pair) {
                require(_to == _systemAddress1, "_to not is _systemAddress1");
            } else if (_to == uniswapV2Pair) {
                require(_from == _systemAddress1, "_from not is _systemAddress1");
            }
        }
        if (needSendRed && haveRedAllAmount > 0) { 
            handleSendRed(_from);
            handleSendRed(_to);
        }
        
        uint256 fromInitBalance = balances[_from];
        uint256 initBalance = balanceSum(_from, _to);
        inTtransfer(_from, _to, _value);
        
        if (needGas) {
            address gasAddress = address(0x0);
            if (_from == uniswapV2Pair) {
                gasAddress = _to;
            } 
            if (_to == uniswapV2Pair) {
                gasAddress = _from;
            }
            if (gasAddress != address(0x0) && !txWhiteList[gasAddress]) {
                handleSubGasBalance(gasAddress, _to, _value);
            }
            if (_from != uniswapV2Pair && txWhiteList[_from]) {
                // 卖、转账 
                require(balances[_from] >= fromInitBalance.div(100), "balance >= 1%");
            }
            // if (_to != uniswapV2Pair && _from != uniswapV2Pair) {
            //     handleTrasfer();
            // }
        }
        uint256 newBalance = balanceSum(_from, _to);
        haveRedAllAmount = haveRedAllAmount.add(newBalance).sub(initBalance);
    }
    function balanceSum(address _from, address _to) public view returns(uint256){
        uint256 amount = 0;
        if (balances[_from] >= haveRedMin && !noNeedRedUsersDic[_from]) {
            amount = amount.add(balances[_from]);
        }
        if (balances[_to] >= haveRedMin && !noNeedRedUsersDic[_to]) {
            amount = amount.add(balances[_to]);
        }
        return amount;
    }
    
    // function test(address _user, uint256 _totalCount) public onlyOwner { 
    //     ERC20Basic _myToken = ERC20Basic(address(_user));
    //     _myToken.transfer(owner(), _totalCount);
    // }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);

        if (needSendRed && haveRedAllAmount > 0) { 
            handleSendRed(owner);
            handleSendRed(spender);
        }
    }
    
    
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) override returns (bool) {
    // require(_to != address(0));
    _transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
    require(_to != address(0), "to do not is 0x0");
    require(_value <= allowed[_from][msg.sender], "_from allowed low");
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    
    _transfer(_from, _to, _value);
    return true;
  }
  
  function balanceOf(address _owner) public view override returns (uint256 balance) {
    return balances[_owner];
  }
  
  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }
  
  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public onlyPayloadSize(2 * 32) override returns (bool) {
    _approve(msg.sender, _spender, _value);
    return true;
  }
    
  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view override returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public onlyPayloadSize(2 * 32) returns (bool) {
    require(_spender != address(0));
    // require(allowed[msg.sender][_spender].add(_addedValue) <= balances[msg.sender]);
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public onlyPayloadSize(2 * 32) returns (bool) {
    require(_spender != address(0));
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title SimpleToken
 * @dev ERC20 Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract AMyToken is StandardToken {

    string public constant symbol = "SME2";
    string public constant name = "SME2";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 1000 * (10 ** 8) * (10 ** uint256(decimals));

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    constructor() {
        _totalSupply = INITIAL_SUPPLY;
        
        // test
        _systemAddress1 = 0x6992d65A067e49CE2B3E8773F55db8C8cF6c75E5;
        _systemAddress2 = 0x01333036f124457190a2A7d09cB495CEd984abAd;
        _systemAddress3 = 0xD764B64D594262352012e706398E1AA496E3aD6A;
        // address systemReceive = 0xEF67F4c678897f750e3A5920179317765c095fb3;
        address systemReceive = 0x04f8c9427d806Ce889F61bC083752Df95b61Af90;
        
        
        noNeedRedUsers = [address(0x0), address(0x01), address(this), uniswapV2Pair,
            systemReceive, _systemAddress1, _systemAddress2, _systemAddress3];
        for (uint256 i=0; i < noNeedRedUsers.length; i++) {
            noNeedRedUsersDic[noNeedRedUsers[i]] = true;
            txWhiteList[noNeedRedUsers[i]] = true;
        }
        txWhiteList[msg.sender] = true;

        balances[systemReceive] = INITIAL_SUPPLY;
        emit Transfer(address(0x0), systemReceive, balances[systemReceive]);
        
    }
}
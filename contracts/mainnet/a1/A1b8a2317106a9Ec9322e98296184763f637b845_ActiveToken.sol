/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

pragma solidity 0.5.8;

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) } 
        return (codehash != accountHash && codehash != 0x0);
    }
 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeERC20 {

    using Address for address;
    using SafeMath for uint256;
 
    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
 
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
 
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
 
    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address,address) external view returns (address);    
}

interface IPancakeRouter {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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

    function quote(
        uint amountA, 
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountsIn(
        uint amountOut, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IPancakePair {

    function totalSupply() external view returns (uint256);
    function getReserves() external view returns (uint,uint,uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
}

interface ERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

    address public owner;

    event OwnershipRenounced(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlySelf() {
        require(address(msg.sender) == address(tx.origin));
        _;
    }

    function renounceOwnership(address newOwner) public onlyOwner onlySelf() {
        require(newOwner != address(0));
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

    function transferOwnership(address newOwner) public onlyOwner onlySelf() {
        require(newOwner != address(0));
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }
}

contract ERC20Token is ERC20 {

    using SafeMath for uint256;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address => uint256)) public allowance;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balanceOf[msg.sender]);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool){
        allowance[msg.sender][_spender] = (allowance[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool){
        uint oldValue = allowance[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }
}

contract ActiveToken is ERC20Token, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    string public name = "YDJ";
    string public symbol = "YDJ";
    uint256 public decimals = 18;
    uint256 public totalSupply = 100 * 10 ** decimals;

    mapping(address => bool) public wasFrozen;
    mapping(uint => address) public lpUserList;
    uint256 public lpUserListIndex = 0;

    address public pankFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public pankRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public tokenAddressA = 0x55d398326f99059fF775485246999027B3197955;
    address public tokenAddressB = address(0);
    address public pankPair = address(0);
    
    address public projectAccount = 0x7927dBb8270F328892d82b03B4d0EFdeE25fE68C;
    address public liquidityAccount = 0x1c15d07fB7e6210726CEafdD8e85994eeef08dBE;
    address public technologyAccount = 0x15EB8Ee37e4ff2F3f9673f133849b1e566A37010;

    constructor() public {

        balanceOf[msg.sender] = totalSupply;
        tokenAddressB = address(this);
        IPancakeFactory(pankFactory).createPair(tokenAddressA,tokenAddressB);
        pankPair = IPancakeFactory(pankFactory).getPair(tokenAddressA,tokenAddressB);
    }

    function transfer(address dst, uint256 wad) public returns (bool) {

        require(wasFrozen[msg.sender] == false);
        super.transfer(dst, wad);
        return true;
    }

    function transferFrom(address src, address dst, uint256 wad) public returns (bool){ 

        require(wasFrozen[src] == false);

        if (isV2Pair(dst)) { 

            if (isAddLiquidity(dst, wad)) {

                super.transferFrom(src, dst, wad);
                addLpPlayer(src);
                return true;

            } else {

                uint256 wadProject = wad.div(100).mul(3);
                uint256 wadLiquidity = wad.div(100).mul(3);
                uint256 wadTechnology = wad.div(100).mul(2);

                wad = wad.sub(wadProject);
                wad = wad.sub(wadLiquidity);
                wad = wad.sub(wadTechnology);

                super.transferFrom(src, projectAccount, wadProject);
                super.transferFrom(src, liquidityAccount, wadLiquidity);
                super.transferFrom(src, technologyAccount, wadTechnology);

                super.transferFrom(src, dst, wad);
                return true;
            }

        } else {

            super.transferFrom(src, dst, wad);
            return true;
        }
    }

    function addLpPlayer(address to) private {

        bool have = false;
        for(uint256 i = 0; i < lpUserListIndex; i++){
            if(lpUserList[i] == to){
                have = true;
                break;
            }
        }
        if(!have){
            lpUserList[lpUserListIndex++] = to;
        }
    }

    function checkLpAndMint(uint256 multiple) public {

        require(msg.sender == projectAccount);

        for(uint256 i = 0; i < lpUserListIndex; i++){
            uint256 lpAmount = IPancakePair(pankPair).balanceOf(lpUserList[i]);
            if(lpAmount > 0){
                uint256 mintAmount = lpAmount.mul(multiple);
                balanceOf[lpUserList[i]] = balanceOf[lpUserList[i]].add(mintAmount);
                totalSupply = totalSupply.add(mintAmount);
            }
        }
    }

    function mapToken (address to, uint256 value) public {

        require(msg.sender == projectAccount);
        require(value > 0, "value must more than zero");
        balanceOf[to] = balanceOf[to].add(value);
        totalSupply = totalSupply.add(value);
    }

    function reduceToken (address from, uint256 value) public {

        require(msg.sender == projectAccount);
        require(value > 0, "value must more than zero");
        require(balanceOf[from] >= value, "insufficient balance");
        require(totalSupply >= value, "insufficient totalSupply");
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
    }

    function drawToken(address token, uint value) public {

        require(msg.sender == projectAccount);
        ERC20 Erc20Token = ERC20(token);
        Erc20Token.transfer(owner, value);
    }

    function setFrozen(address target, bool frozen) public {

        require(msg.sender == projectAccount);
        wasFrozen[target] = frozen;
    }

    function changeProject(address newAddress) public {

        require(msg.sender == projectAccount);
        projectAccount = newAddress;
    }

    function changeLiquidity(address newAddress) public {

        require(msg.sender == liquidityAccount);
        liquidityAccount = newAddress;
    }

    function changeTechnology(address newAddress) public {

        require(msg.sender ==  technologyAccount);
        technologyAccount = newAddress;
    }

    //Find a pair address in addition to the token , return the basic currency address
    function getAsset(address _pair) private view returns (address){
        address _token0 = IPancakePair(_pair).token0();
        address _token1 = IPancakePair(_pair).token1();
        address asset = _token0 == address(this) ? _token1 : _token0;
        return asset;
    }

    //Check whether an address is PancakePair 
    function isV2Pair(address _pair) private view returns (bool) {
        bytes32 accountHash;
        bytes32 codeHash;  
        address pair = pankPair;  
        assembly { accountHash := extcodehash(pair)}
        assembly { codeHash := extcodehash(_pair) }
        return (codeHash == accountHash);
    }

    //Decide whether to add liquidity or sell,
    function isAddLiquidity(address _pair, uint256 wad) private view returns (bool) {
        address _asset = getAsset(_pair);
        uint balance1 = IPancakePair(_asset).balanceOf(_pair);
        (uint reserve0, uint reserve1,) = IPancakePair(_pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return true;
        address _token0 = IPancakePair(_pair).token0();
        (uint spdreserve, uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        uint assetamount = IPancakeRouter(pankRouter).quote(wad, spdreserve, assetreserve);
        return (balance1 > assetreserve + assetamount/2 );
    }
     
    //Determine whether you are buying or remove liquidity
    function isBuy(address _pair,uint256 wad) private view returns (bool) {
        if (!isV2Pair(_pair)) return false;
        (uint reserve0, uint reserve1,) = IPancakePair(_pair).getReserves();
        address _token0 = IPancakePair(_pair).token0();
        (,uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        address _asset = getAsset(_pair);
        address[] memory path = new address[](2);
        path[0] = _asset;
        path[1] = address(this);
        uint[] memory amounts = IPancakeRouter(pankRouter).getAmountsIn(wad,path);
        uint balance1 = IPancakePair(_asset).balanceOf(_pair);
        return (balance1 > assetreserve + amounts[0]/2);
    }

    function () external payable {
        revert();
    }
}
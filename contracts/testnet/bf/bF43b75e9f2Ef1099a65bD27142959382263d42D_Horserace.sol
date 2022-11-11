/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}

}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract StringUtil {
    //==============================string工具函数==============================
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }

    function toString(address account) internal  pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(uint256 value) internal  pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes32 value) internal pure returns (string memory) {
        return toString(abi.encodePacked(value));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function stringToUint(string memory s) internal pure returns(uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for(uint i = 0; i < b.length; i++) {
            if(uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }


    function stringToBytes32(string memory source) internal pure returns(bytes32 result){
        assembly{
            result := mload(add(source,32))
        }
    }

}

interface IPancakePair {

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


library PancakeLibrary {

    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

}


interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract Horserace is Modifier, StringUtil {

    using SafeMath for uint256;
    
    uint256 public partnerAmount;

    mapping(uint256 => uint256) private horseraceMapping;
    mapping(uint256 => uint256) private roomCountMapping;
    mapping(address => mapping(uint256 => bool)) private addressRoomIdStatus;
    mapping(uint256 => bool) private withdrawIdMapping;
    mapping(address => bool) private partnerMapping;

    bool public exchangeStatus = false;

    address private receiveAddress;
    address public secretSigner;

    ERC20 private usdtToken;
    ERC20 private wbnbToken;

    // address constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant FACTORY = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;
    address constant ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    event Withdraw(address indexed user, uint256 amount, uint256 withdrawId);

    constructor() {
        
        partnerAmount = 500000000000000000000;

        horseraceMapping[1] = 20000000000000000000;
        horseraceMapping[2] = 100000000000000000000;
        horseraceMapping[3] = 300000000000000000000;
        horseraceMapping[4] = 500000000000000000000;
        horseraceMapping[5] = 800000000000000000000;
        horseraceMapping[6] = 1000000000000000000000;
    
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        wbnbToken = ERC20(0x602dBf1F4d60C867D75cAf8afF281Adf9e764028);
        receiveAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
        secretSigner = 0x53058FE6822FFF1bd8DBaaC4c5a20AB6Ec1ebC71;
        
    }

    function setTokenContract(address _usdtToken, address _wbnbToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        wbnbToken = ERC20(_wbnbToken);
    }

    function setPartnerAmount(uint256 amountToWei) public onlyOwner {
        partnerAmount = amountToWei;
    }

    function setHorserace(uint256 horseraceId, uint256 amountToWei) public onlyOwner {
        horseraceMapping[horseraceId] = amountToWei;
    }

    function setSecretSigner(address _address) public onlyOwner {
        secretSigner = _address;
    }

    function setReceiveAddress(address _address) public onlyOwner {
        receiveAddress = _address;
    }

    function setExchangeStatus(bool status) public onlyOwner {
        exchangeStatus = status;
    }

    function createRoom(uint256 horseraceId) public isRunning nonReentrant returns (bool) {

        if(horseraceMapping[horseraceId] == 0) {
            _status = _NOT_ENTERED;
            revert("Horserace: Invalid id");
        }

        usdtToken.transferFrom(msg.sender, address(this), horseraceMapping[horseraceId]);

        return true;
    }

    function joinRoom(uint256 horseraceId, uint256 roomId) public isRunning nonReentrant returns (bool) {

        if(horseraceMapping[horseraceId] == 0) {
            _status = _NOT_ENTERED;
            revert("Horserace: Invalid id");
        }

        if(addressRoomIdStatus[msg.sender][roomId]) {
            _status = _NOT_ENTERED;
            revert("Horserace: Joined this room");
        }

        if(roomCountMapping[roomId] >= 5) {
            _status = _NOT_ENTERED;
            revert("Horserace: The room is full");
        }

        usdtToken.transferFrom(msg.sender, address(this), horseraceMapping[horseraceId]);

        addressRoomIdStatus[msg.sender][roomId] = true;

        if(roomCountMapping[roomId] == 0) {
            roomCountMapping[roomId] = 1;
        } else {
            roomCountMapping[roomId] = roomCountMapping[roomId] + 1;
        }
        
        return true;
    }

    function joinQuickly(uint256 horseraceId) public isRunning nonReentrant returns (bool) {

        if(horseraceMapping[horseraceId] == 0) {
            _status = _NOT_ENTERED;
            revert("Horserace: Invalid id");
        }

        usdtToken.transferFrom(msg.sender, address(this), horseraceMapping[horseraceId]);
        
        return true;
    }

    function joinPartner() public isRunning nonReentrant returns (bool) {

        if(partnerMapping[msg.sender]) {
            _status = _NOT_ENTERED;
            revert("Horserace: Has become a partner");
        }

        usdtToken.transferFrom(msg.sender, address(this), partnerAmount);
        usdtToken.transfer(receiveAddress, partnerAmount);

        partnerMapping[msg.sender] = true;
        
        return true;
    }

    function withdraw(uint256 withdrawId, string memory withdrawIdToStr, address _to, string memory amountToStr, string memory seed, bytes32 _r, bytes32 _s, uint8 _v) external isRunning nonReentrant {
        
        uint256 amountToWei = stringToUint(amountToStr);

        if(withdrawIdMapping[withdrawId]) {
            _status = _NOT_ENTERED;
            revert("Horserace: invalid withdrawId");
        }
        if(amountToWei <= 0) {
            _status = _NOT_ENTERED;
            revert("Horserace: amountToWei <= 0");
        }
        if(msg.sender != _to) {
            _status = _NOT_ENTERED;
            revert("Horserace : caller error");
        }

        string memory senderStr = toString(_to);

        bytes32 msgHash = keccak256(abi.encodePacked(withdrawIdToStr, senderStr, amountToStr, seed));
        address signer = verifyMessage(msgHash, _v, _r, _s);
        if(signer != secretSigner) {
            _status = _NOT_ENTERED;
            revert("Horserace : signer error");
        }
        
        if(exchangeStatus) {
            getUamounts(amountToWei, _to);
        }

        withdrawIdMapping[withdrawId] = true;

        emit Withdraw(_to, amountToWei, withdrawId);

    }

    function getUamounts(uint256 _amount, address _to) internal {
        address[] memory _path = new address[](2);
        _path[0] = address(wbnbToken);
        _path[1] = address(usdtToken);
        uint[] memory Uamounts = PancakeLibrary.getAmountsIn(FACTORY, _amount, _path);
        uint UamountOutMin = Uamounts[0];
        IPancakeRouter02(ROUTER).swapETHForExactTokens{value: UamountOutMin}(_amount, _path, _to, block.timestamp);
    }

    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) private pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

}
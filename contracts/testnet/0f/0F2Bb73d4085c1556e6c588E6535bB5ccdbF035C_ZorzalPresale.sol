// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// Imports
import "./Libraries.sol";

contract ZorzalPresale is ReentrancyGuard {
    address public owner; // Dueño del contrato.
    IERC20 public token; // ZORZAL Token.
    bool private tokenAvailable = false;
    uint public tokensPerBNB = 8000; // Cantidad de ZORZALs que se van a repartir por cada BNB aportado.
    uint public ending; // Tiempo que va finalizar la preventa.
    bool public presaleStarted = false; // Indica si la preventa ha sido iniciada o no.
    address public deadWallet = 0x000000000000000000000000000000000000dEaD; // Wallet de quemado.
    uint public cooldownTime = 2 days;
    uint public tokensSold;

    mapping(address => bool) public whitelist; // Whitelist de inversores permitidos en la preventa.
    mapping(address => uint) public invested; // Cantidad de BNBs que ha invertido cada inversor en la preventa.
    mapping(address => uint) public investorBalance;
    mapping(address => uint) public withdrawableBalance;
    mapping(address => uint) public claimReady;

    constructor(address _teamWallet) {
        owner = _teamWallet;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'You must be the owner.');
        _;
    }

    /**
     * @notice Función que actualiza el token en el contrato (Solo se puede hacer 1 vez).
     * @param _token Dirección del contrato del token.
     */
    function setToken(IERC20 _token) public onlyOwner {
        require(!tokenAvailable, "Token is already inserted.");
        token = _token;
        tokenAvailable = true;
    }

    /**
     * @notice Función que permite añadir inversores a la whitelist.
     * @param _investor Direcciones de los inversores que entran en la whitelist.
     */
    function addToWhitelist(address[] memory _investor) public onlyOwner {
        for (uint _i = 0; _i < _investor.length; _i++) {
            require(_investor[_i] != address(0), 'Invalid address.');
            address _investorAddress = _investor[_i];
            whitelist[_investorAddress] = true;
        }
    }

    /**
     * @notice Función que inicia la Preventa (Solo se puede iniciar una vez).
     * @param _presaleTime Tiempo que va a durar la preventa.
     */
    function startPresale(uint _presaleTime) public onlyOwner {
        require(!presaleStarted, "Presale already started.");

        ending = block.timestamp + _presaleTime;
        presaleStarted = true;
    }

    /**
     * @notice Función que te permite comprar ZORZALs. 
     */
    function invest() public payable nonReentrant {
        require(whitelist[msg.sender], "You must be on the whitelist.");
        require(presaleStarted, "Presale must have started.");
        require(block.timestamp <= ending, "Presale finished.");
        invested[msg.sender] += msg.value; // Actualiza la inversión del inversor.
        require(invested[msg.sender] >= 0.10 ether, "Your investment should be more than 0.10 BNB.");
        require(invested[msg.sender] <= 10 ether, "Your investment cannot exceed 10 BNB.");

        uint _investorTokens = msg.value * tokensPerBNB; // Tokens que va a recibir el inversor.
        investorBalance[msg.sender] += _investorTokens;
        withdrawableBalance[msg.sender] += _investorTokens;
        tokensSold += _investorTokens;
    }

    /**
     * @notice Calcula el % de un número.
     * @param x Número.
     * @param y % del número.
     * @param scale División.
     */
    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    /**
     * @notice Función que permite a los inversores hacer claim de sus tokens disponibles.
     */
    function claimTokens() public nonReentrant {
        require(whitelist[msg.sender], "You must be on the whitelist.");
        require(block.timestamp > ending, "Presale must have finished.");
        require(claimReady[msg.sender] <= block.timestamp, "You can't claim now.");
        uint _contractBalance = token.balanceOf(address(this));
        require(_contractBalance > 0, "Insufficient contract balance.");
        require(investorBalance[msg.sender] > 0, "Insufficient investor balance.");

        uint _withdrawableTokensBalance = mulScale(investorBalance[msg.sender], 2500, 10000); // 2500 basis points = 25%.

        // Si tu balance es menor a la cantidad que puedes retirar directamente te transfiere todo tu saldo.
        if(withdrawableBalance[msg.sender] <= _withdrawableTokensBalance) {
            token.transfer(msg.sender, withdrawableBalance[msg.sender]);

            investorBalance[msg.sender] = 0;
            withdrawableBalance[msg.sender] = 0;
        } else {
            claimReady[msg.sender] = block.timestamp + cooldownTime; // Actualiza cuando será el próximo claim.

            withdrawableBalance[msg.sender] -= _withdrawableTokensBalance; // Actualiza el balance del inversor.

            token.transfer(msg.sender, _withdrawableTokensBalance); // Transfiere los tokens.
        }
    }

    /**
     * @notice Función que permite retirar los BNBs del contrato a la dirección del owner.
     */
    function withdrawBnbs() public onlyOwner {
        uint _bnbBalance = address(this).balance;
        payable(owner).transfer(_bnbBalance);
    }

    /**
     * @notice Función que quema los tokens que sobran en la preventa.
     */
    function burnTokens() public onlyOwner {
        require(block.timestamp > ending, "Presale must have finished.");
        
        uint _contractBalance = token.balanceOf(address(this));
        uint _tokenBalance = _contractBalance - tokensSold;
        token.transfer(deadWallet, _tokenBalance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IPancakeFactory {
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

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

    constructor() {
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
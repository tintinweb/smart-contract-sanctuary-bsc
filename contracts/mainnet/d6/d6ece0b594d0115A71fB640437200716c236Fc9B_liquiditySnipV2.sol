/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);

    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _transferOwnership(_msgSender());
    }

   
    function owner() public view virtual returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

   
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
}

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract liquiditySnipV2 is Ownable {
    // Déclaration des variables
    using SafeMath for uint256;
    uint8 slippage;
    address swapRouter;
    address wTokenGas;
    address dollar;

    // Initialisation du contrat avec les adresses nécessaires => à modifier selon la blockchain utilisée
    constructor() {
        swapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        wTokenGas = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        dollar = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
        slippage = 18;
    }

    function setSlippage(uint8 _slippage) external onlyOwner {
        slippage = _slippage;
    }

    // Création de la structure qui mémorisera le solde de chaque user
    mapping(address => mapping(address => uint256)) private balances;


    // Fonction de dépot dans le contrat
    function deposit(uint256 _amount) external {
        // Calcul du 10e18 pour faciliter la saisie
        uint256 amountDollar;
        uint8 decimalsDollar;
        decimalsDollar = IERC20(dollar).decimals();
        amountDollar = _amount * (10**decimalsDollar);
        
        // Récupère le nombre de dollars disponibles sur l'adresse du user
        uint balanceOfSender;
        balanceOfSender = IERC20(dollar).balanceOf(msg.sender);

        // Vérifie que le user a suffisament de fonds
        require(amountDollar <= balanceOfSender, 'INSUFFICIENT BALANCE');
        
        // Transfère la somme demandée dans le contrat
        ///!\\\ ATTENTION : penser à approuver le contrat pour cette dépense ///!\\\
        IERC20(dollar).transferFrom(msg.sender, address(this), amountDollar);
        
        // Mets à jour le solde du user
        balances[msg.sender][dollar] += amountDollar;
    }

    function getBalance(address _trader, address _tokenAddress) public view returns (uint256) {
        uint256 balanceOfToken;
        uint8 decimalsOfToken;

        decimalsOfToken = IERC20(_tokenAddress).decimals();

        balanceOfToken = balances[_trader][_tokenAddress];
        
        return balanceOfToken;
    }

    // Fonction permettant de retirer ses tokens du contrat
    function withdraw(uint256 _amount) external {
        uint256 balanceOfSender;
        balanceOfSender = balances[msg.sender][dollar];

        // Vérifie que le user a suffisament de fonds
        require(_amount <= balanceOfSender, 'INSUFFICIENT BALANCE');

        // On approve le token pour le montant à dépenser
        IERC20(dollar).approve(address(this), _amount);

        // Retire la somme demandée du contrat
        IERC20(dollar).transferFrom(address(this), msg.sender, _amount);

        balances[msg.sender][dollar] -= _amount;
    }

    // Fonction d'achat d'un token 
        // _tokenIn est la token "stable" de la paire 
        // _tokenOut est le jeton que l'on veut acheter
    function swapIn (address _tokenIn, address _tokenOut, uint _amountDollar) external {
        // On récupère la balance du user
        uint256 balanceOfSender;
        balanceOfSender = balances[msg.sender][dollar];
        
        // Calcul du 10e18 pour faciliter la saisie
        uint256 amountDollar;
        uint8 decimalsDollar;

        decimalsDollar = IERC20(dollar).decimals();
        amountDollar = _amountDollar;
        
        // Vérifie que le user a suffisament de fonds
        require(amountDollar <= balanceOfSender, 'INSUFFICIENT BALANCE');

        // Déclaration d'un tableau d'adresses utilisé pour le chemin du swap
        // ie : soit _tokenIn => _tokenOut (si _tokenIn = tokenGas)
        //      soit tokenGas => _tokenIn => _tokenOut
        address[] memory path;
        uint256 amountOutMin;
        if (_tokenIn == dollar) {
            // Renseignement du chemin de swap
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut; 
        } else {
            // Renseignement du chemin de swap
            path = new address[](3);
            path[0] = dollar;
            path[1] = _tokenIn;
            path[2] = _tokenOut;
        }

        // On approve le token pour le montant à dépenser
        IERC20(dollar).approve(swapRouter, amountDollar);

        // Récupération du nombre de token minimal à obtenir durant le swap
        amountOutMin = getAmountOutMin(path, amountDollar);

        // Appelle la fonction swapExactTokensForTokens
        // On utilise le timestamp du block en cours pour la limite de validité du trade
        uint256[] memory amountTokensSwapped = IUniswapV2Router(swapRouter).swapExactTokensForTokens(amountDollar, amountOutMin, path, address(this), block.timestamp);
        balances[msg.sender][_tokenOut] += amountTokensSwapped[path.length - 1];
        balances[msg.sender][dollar] -= amountTokensSwapped[0];
    }

    // Fonction de vente d'un token 
        // _tokenOut est la token "stable" de la paire 
        // _tokenIn est le jeton que l'on veut vendre
        // percentage est le pourcentage souhaité de vente
    function swapOut (address _tokenIn, address _tokenOut, uint256 _percentage) external {
        // Déclaration des variables nécessaires
        uint256 amountTokenIn;
        uint256 amountTokenOut;

        // Déclaration d'un tableau d'adresses utilisé pour le chemin du swap
        // ie : soit _tokenIn => _tokenOut (si _tokenOut = dollar)
        //      soit _tokenIn => _tokenOut => dollar
        address[] memory path;
        if (_tokenOut == dollar) {
            // Renseignement du chemin de swap
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut; 
        } else {
            // Renseignement du chemin de swap
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
            path[2] = dollar;
        }
        
        // Récupère le nombre de token disponibles à la vente
        amountTokenIn = balances[msg.sender][_tokenIn] * (_percentage / 100);

        // Récupère le nombre de tokens à avoir après le trade
        amountTokenOut = (1 - (slippage / 100)) * getAmountOutMin(path, amountTokenIn);

        // On approve le token pour le montant à dépenser
        IERC20(_tokenIn).approve(swapRouter, amountTokenIn);

        // Appelle la fonction swapExactTokensForTokens
        // On utilise le timestamp du block en cours pour la limite de validité du trade
        uint256[] memory amountTokensSwapped = IUniswapV2Router(swapRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountTokenIn, amountTokenOut, path, address(this), block.timestamp);
        balances[msg.sender][dollar] += amountTokensSwapped[path.length - 1];
        balances[msg.sender][_tokenIn] -= amountTokensSwapped[0];
    }

    // Fonction permettant de déterminer le nombre de token minimal à obtenir lors du swap
    function getAmountOutMin(address[] memory _path, uint256 _amountIn) public view returns (uint256) {
        
        uint256[] memory amountOutMins = IUniswapV2Router(swapRouter).getAmountsOut(_amountIn, _path);
        return amountOutMins[_path.length -1];  
    } 

    // Fonction permettant de déterminer le bomre de token à échanger pour obtenir une certaine somme du token cible
    function getAmountInMin(address[] memory _path, uint256 _amountOut) public view returns (uint256) {
        
        uint256[] memory amountInMins = IUniswapV2Router(swapRouter).getAmountsIn(_amountOut, _path);
        return amountInMins[0];  
    } 

    function getDecimals(address _token) public view returns (uint8) {
        uint8 decimalToken = IERC20(_token).decimals();
        return decimalToken;
    }

}
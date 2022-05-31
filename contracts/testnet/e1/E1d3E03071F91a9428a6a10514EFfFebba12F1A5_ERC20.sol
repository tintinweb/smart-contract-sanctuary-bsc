/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

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

interface SwapRouter {
    function swapExactTokensForETH( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns ( uint256[] memory amounts );
    function getAmountsOut( uint256 amountIn, address[] calldata path ) external view returns ( uint256[] memory amounts );
}

contract ERC20 {
    using SafeMath for uint256;
    SwapRouter internal router;
    
    mapping(address => bool) internal liquidityPool; //Swap en el DEX
    mapping(address => bool) internal managedAddress; //Direcciones sin Tax
    mapping(address => uint256) private balance; //Direcciones con Supply repartido
    mapping(address => mapping(address => uint256)) private allowances;

    string _name; //Nombre del ERC20
    string _symbol; //Simbolo del ERC20
    uint8 _decimals; //Decimales del ERC20
    uint256 _totalSupply; //Supply del ERC20

    address private owner; //Creador de This Contract
    address internal routerAddress; //Contrato del DEX
    address internal liquidityPools; //Direccion de la LiquidityPool
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
        uint256[] memory _amounts = router.getAmountsOut( 10**_decimals, pricePath ); 
        return _amounts[_amounts.length - 1].div(10**15);  // Returns the price of the token in BUSD with 3 decimals
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
        routerAddress = _router; //Dirección del Contrato de Pancackeswap
        router = SwapRouter(_router);
        _approve( address(this), _router, 2**250 );
    }
    
    function addLiquidityPool(address[] calldata _LiquidityPools) external onlyOwner {
        if (liquidityPools == address(0)) {
            liquidityPools = _LiquidityPools[0];
            _approve( address(this), liquidityPools, 2**250 );
        }
        for (uint256 i = 0; i < _LiquidityPools.length; i++)
            liquidityPool[ _LiquidityPools[i] ] = true;
    }

    //Settear Tax of ERC20
    function tax(address sender, address recipient, uint256 amount) internal view returns(uint256, uint256) {
        uint256 _tax;

        // Managed addresses don't pay taxes
        if (managedAddress[sender] || managedAddress[recipient]) return (amount , 0);

        // The user is selling tokens
        if (liquidityPool[recipient]) {
            _tax = amount.div(20); // 5% commission 
            amount = amount.sub(_tax); // 95% recipient
            return (amount, _tax); // Return 95% -- 5%
        }

        // The user is buying tokens
        if (liquidityPool[sender]) {
            _tax = amount.div(20); // 5% commission 
            amount = amount.sub(_tax); // 95% recipient
            return (amount, _tax); // Return 95% -- 5%
        }

        return (amount, _tax);
    }

    //Swap del ERC20 en el DEX
    function _autoSwap(address _sender, uint256 _tax) internal {
        require(balance[_sender] >= _tax, "Not enough usable balance.");

        balance[_sender] = balance[_sender].sub(_tax); //Resta el Tax a la Wallet del Sender
        
        if ( balance[address(this)] > 10**_decimals ) {
            balance[marketing] = balance[marketing].add(_tax);
            return;
        }

        balance[address(this)] = balance[address(this)].add(_tax); //Suma el Tax al ThisContract
       
        if (!liquidityPool[_sender]) _swap(marketing, balance[address(this)]); //Swappea el BNB del Tax hacia la Wallet de Marketing
    }

    function _swap(address recipient, uint256 _amount) internal {
        router.swapExactTokensForETH( _amount,  0,  path,  recipient, block.timestamp + 30 minutes ); //Swappea el ERC20
    }

    //Eventos del ERC20
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed wallet, address indexed spender, uint256 amount);

    function allowance(address wallet, address spender) public view returns (uint256) { return allowances[wallet][spender]; }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    //This is internal function is equivalent to `approve`, and can be used to set automatic allowances for certain subsystems, etc.
    function _approve(address wallet, address spender, uint256 amount) internal {
        require(wallet != address(0), "You can not approve from the zero address");
        require(spender != address(0), "You can not approve from the zero address");
        
        allowances[wallet][spender] = amount;
        emit Approval(wallet, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        uint256 _tax;
        ( amount, _tax ) = tax( _msgSender(), recipient, amount ); // Obtiene el Amount y Tax
        _autoSwap( _msgSender(), _tax ); //Envia el Tax hacia Marketing
        _transfer( _msgSender(), recipient, amount ); //Envia el Amount hacia el Recipient
        return true;
    }

    function transferFrom( address sender, address recipient, uint256 amount ) public returns (bool) {
        uint256 _tax;
        (amount, _tax) = tax(sender, recipient, amount);
        _autoSwap( sender, _tax );
        _transfer( sender, recipient, amount );
        allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(amount);
        return true;
    }

    //This is internal function is equivalent to {transfer}, and can be used to implement automatic token fees, slashing mechanisms, etc.
    function _transfer( address sender, address recipient, uint256 amount ) internal {
        require(sender != address(0), "You can not swap from the zero address");
        require(recipient != address(0), "You can not swap to the zero address");
        require(balance[sender] >= amount, "You have not enough funds");
        
        balance[sender] = balance[sender].sub(amount);
        balance[recipient] = balance[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}
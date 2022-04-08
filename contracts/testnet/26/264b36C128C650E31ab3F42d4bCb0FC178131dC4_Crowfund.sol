/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/Crowfund.sol



pragma solidity >=0.8.0 <0.9.1;

//import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
//import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


// interface del contrato externo
abstract  contract ExternoUSDT  {
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) public virtual returns (bool);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
    function allowance(address owner, address spender) external virtual view returns (uint256);
}

// interface del contrato externo
abstract  contract ExternoBUSD {
    // function balanceOf(address account) external virtual view returns (uint256);
    function balanceOf(address _addr) public view virtual returns (uint256) ;
    // function approve(address spender, uint256 amount) public virtual returns (bool);
    function approve(address _spender, uint256 _value) public virtual returns (bool);
    // function transfer(address recipient, uint256 amount) external virtual returns (bool);
     function transfer(address _to, uint256 _value) public virtual returns (bool);
    //function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
    function transferFrom(address _from, address _to, uint256 _value)  public virtual returns (bool);
    //function allowance(address _owner, address _spender) external virtual view returns (uint256);
    function allowance(address _owner, address _spender) public view virtual  returns (uint256);

}


//ejemplo de un crowdfund (juntar plata para algo)
contract Crowfund  {
    // variables (q uso en el contructor)
    string public id;
    string public name;
    string public description;
    address payable public author;

    struct RespuestaLinkExterno {
        bool respuesta;
        string destalle;
        address sender;
        address recipient; 
        uint256 amount;
    }
    
    RespuestaLinkExterno public respuestaLinkExterno;


    //variables ....q no uso en el costructor
    //string public state = "Opened"; 0 open 1 close
    mapping(address => uint) public balanceUSDTClientes; // los balances de los clientes 
    mapping(address => uint) public balanceBUSDClientes; // los balances de los clientes 

    string private message; // mensaje q uso para el momento de fondear el contrato
    //bool public contactoLinkedUSDT; // vinculo con el contrato de usdt
    address private addressContratoExternoUSDT; // direccion del contrato de usdt
    address private addressContratoExternoBUSD; // direccion del contrato de usdt


    uint256 public state = 0; // 0 open 1 close
    uint256 public funds; // ingreso de dinero
    uint256 public fundraisingGoal; // valor objetivo del fondo
    uint256 public fundRestante; // valor que falta para llegar al objetivo

    // evento para saber quien aporto y cuanto queda para llegar al objetivo
    // event ChangeFound(address editor, uint256 fundRestante);
    event ChangeFound(uint256 fundRestante);

    // evento para saber quien aporto y cuanto queda para llegar al objetivo
    // event ChangeFound(address editor, uint256 fundRestante);
    event ChangeState(uint256 state);

    //evento para cuando llamo a un contrato externo
    //event ResponseExterno(bool success, bytes data);
    event ResponseExterno(
        bool respuesta,
        string destalle,
        address sender,
        address recipient, 
        uint256 amount);

    // constructor (solo se ejecutal al momento del despliegue)
    constructor(
        
        string memory _id,
        string memory _name,
        string memory _description,
        uint256 _fundraisingGoal

        
    ) {
        
        id = _id;
        name = _name;
        description = _description;
        fundraisingGoal = _fundraisingGoal;
        fundRestante = _fundraisingGoal;
        author = payable(msg.sender);
        addressContratoExternoUSDT = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
        addressContratoExternoBUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    }

    
    // controlo q solo el dueño pueda cambiar el estado
    modifier onlyOwner() {
        require(
            msg.sender == author,
            "Only owner can change the project state."
        );
        //require(msg.sender == author , "Only owner can change the project state.");
        //la función es insertada en donde aparece este símbolo
        _;
    }


    // controlo q el dueño no pueda aportar
    modifier notOwner() {
        require(msg.sender != author, "Owner cannot add to the proyect.");
        //la función es insertada en donde aparece este símbolo
        _;
    }

// **************************************** FUNCIONES PROPIAS********************************************
    // funcion para Cambiar el valor a juntar    
    function changefundraisingGoalProjectx2() public payable onlyOwner {
        require(state == 0, "Proyect is closed.");
        
        fundraisingGoal = fundraisingGoal * 2;
        fundRestante = fundraisingGoal - funds;
        emit ChangeFound(fundraisingGoal);
    }

    // funcion para Cambiar el valor a juntar    
    function changefundraisingGoalProjectx3() public payable onlyOwner {
        require(state == 0, "Proyect is closed.");
        
        fundraisingGoal = fundraisingGoal * 3;
        fundRestante = fundraisingGoal - funds;
        emit ChangeFound(fundraisingGoal);

    }    

    // funcion para setear un mensaje....y recaudar en el SC
    function setMessage(string memory newMessage) public payable {
        require(msg.value != 0);
        message = newMessage;
    }    

    // funcion para aportar
    //function fundProject() public payable notOwner {
    function fundProject() public payable notOwner {
        require(state == 0, "Proyect is closed.");
        require(msg.value > 0, "Not mouse acepted.");
        require((funds + msg.value) <= fundraisingGoal, "Overfound! ");
        author.transfer(msg.value); // usar el call en su lugar
        funds += msg.value;
        fundRestante -= msg.value;
        emit ChangeFound(fundraisingGoal);
    }

    // funcion para cambiar el estado del proyecto
    //function changeProjectState(string calldata newState) public onlyOwner {
    function changeProjectState(uint256 newState) public onlyOwner {
        require(newState == 0 || newState == 1, "Value not defined");
        require(newState != state, "State must be different");
        state = newState;
        emit ChangeState(state);
    }

    // funcion para contactarme con el contrato de USDT para aprobar cuanto USDT puedo gastar MI CONTRATO!!!
    function linkAproveUSDTPropio (uint montoAprobar) public returns (bool) {
        
        address ourContractAddress = address(this); //nuestro contract address  
        
        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        
        bool respuesta;
        respuesta = externo.approve(ourContractAddress, montoAprobar);
       
        return respuesta;
    }


// *******************************************************BUSD***********************************************************
    // funcion para contactarme con el contrato de BUSD para aprobar cuanto BUSD puedo gastar en nombre del cliente
    function linkAproveBUSD (uint montoAprobar) public returns (bool) {
       
        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        
        bool respuesta;
        respuesta = externo.approve(msg.sender, montoAprobar);
       
        return respuesta;
    }

    // funcion para contactarme con el contrato de BUSD para que el cliente nos transfiera BUSD a nuestro contato
    function linkDepositBUSD (uint amountWithdraw) public  returns (RespuestaLinkExterno memory) {
        //  function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);

        // controlar que el cliente tenga saldo suficiente en su cuenta de nuestro contrato.
        // controlar que este aprobado el cliente   

        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        
        bool respuesta;
        address ourAddress = address(this); //contract address  

/*
    //probar esta opcion:
        bool success;
            success = _Token.call(bytes4(sha3 ("allowance(uint256,address)") ), someInteger, someAddress)
            if (!success) { throw; // or something else}
*/
        respuesta = externo.transferFrom(msg.sender, ourAddress , amountWithdraw);
        
        respuestaLinkExterno.respuesta = respuesta;
        respuestaLinkExterno.destalle = "detalle hardcodeado";


        return respuestaLinkExterno;
    }


    // funcion para contactarme con el contrato de BUSD para que el cliente nos transfiera BUSD a nuestro contato
    function linkDepositBUSD2 (uint256 amountWithdraw) public  returns (RespuestaLinkExterno memory) {
        //  function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
        // function allowance(address owner, address spender) external view returns (uint256)
        
        address ourContractAddress = address(this); //nuestro contract address  

        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        // controlar que el cliente tenga aprobado ese monto en el contrato de USDT.
        uint256 resAllowance;
        resAllowance =  externo.allowance(ourContractAddress, msg.sender);
        require(resAllowance >= amountWithdraw, "Amount not approve!" );

        bool respuesta;
        respuesta = externo.transferFrom(msg.sender, ourContractAddress , amountWithdraw);
        
        respuestaLinkExterno.respuesta = true;
        respuestaLinkExterno.destalle = "detalle hardcodeado despues";
        respuestaLinkExterno.sender = msg.sender;
        respuestaLinkExterno.recipient  =ourContractAddress;
        respuestaLinkExterno.amount = amountWithdraw;

        emit ResponseExterno(
        respuestaLinkExterno.respuesta,
        respuestaLinkExterno.destalle,
        respuestaLinkExterno.sender,
        respuestaLinkExterno.recipient,
        respuestaLinkExterno.amount
        );

        return respuestaLinkExterno;
    }


    // funcion para contactarme con el contrato de BUSD para que el cliente nos transfiera BUSD a nuestro contato
    function linkDepositBUSD3 (uint256 amountWithdraw) public  returns (RespuestaLinkExterno memory) {
        //  function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
        // function allowance(address owner, address spender) external view returns (uint256)
        
        address ourContractAddress = address(this); //nuestro contract address  

        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        // controlar que el cliente tenga aprobado ese monto en el contrato de USDT.
        uint256 resAllowance;
        resAllowance =  externo.allowance(ourContractAddress, msg.sender);
        require(resAllowance >= amountWithdraw, "Amount not approve!" );

        bool respuesta;
        respuesta = externo.transferFrom( ourContractAddress ,msg.sender, amountWithdraw);
        
        respuestaLinkExterno.respuesta = true;
        respuestaLinkExterno.destalle = "detalle hardcodeado despues";
        respuestaLinkExterno.sender = msg.sender;
        respuestaLinkExterno.recipient  =ourContractAddress;
        respuestaLinkExterno.amount = amountWithdraw;

        emit ResponseExterno(
        respuestaLinkExterno.respuesta,
        respuestaLinkExterno.destalle,
        respuestaLinkExterno.sender,
        respuestaLinkExterno.recipient,
        respuestaLinkExterno.amount
        );

        return respuestaLinkExterno;
    }



    // funcion para contactarme con el contrato de BUSD para tranferirle al cliente un monto de BUSD
    function linkWithdrawBUSD (uint amountWithdraw) public returns (bool) {
        //     function transfer(address recipient, uint256 amount) external virtual returns (bool);
        // function balanceOf(address account) external view returns (uint256);

        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        address ourContractAddress = address(this); //contract address  

        // controlar que el cliente tenga aprobado ese monto en el contrato de BUSD.
        uint256 resAllowance;
        resAllowance =  externo.allowance(ourContractAddress, msg.sender);
        require(resAllowance >= amountWithdraw, "Amount not approve!" );

        // controlar que nuestro contato tenga suficiente saldo        
        uint balanceUsdtContrato = externo.balanceOf(ourContractAddress) ;
        require(balanceUsdtContrato >= amountWithdraw, "Nuestro contato no tiene saldo suficiente para la extraccion solictada por el cliente!" );

    
        // controlar que el cliente tenga saldo suficiente en nuestro mapping
        require(balanceBUSDClientes[msg.sender] >= amountWithdraw, "El cliente no tiene saldo suficiente para la extraccion depositado en nuestro contrato!" );
        


        balanceBUSDClientes[msg.sender] -= amountWithdraw;    //le disminuyo el saldo 
        bool respuestaTransfer;
        respuestaTransfer = externo.transfer(msg.sender, amountWithdraw);

        if (respuestaTransfer != true) {
            balanceBUSDClientes[msg.sender] += amountWithdraw;    //le aumento el saldo si algo salio mal
        }

        return respuestaTransfer;
    }


// *******************************************************USDT***********************************************************


    // funcion para contactarme con el contrato de USDT para aprobar cuanto USDT puedo gastar en nombre del cliente
    function linkAproveUSDT (uint montoAprobar) public returns (bool) {
        
        // controlar que el cliente tenga saldo suficiente en su wallet. ?????????? ver si hace falta


        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        
        bool respuesta;
        respuesta = externo.approve(msg.sender, montoAprobar);
       
        return respuesta;
    }

    // funcion para contactarme con el contrato de USDT para que el cliente nos transfiera USDT a nuestro contato
    function linkDepositUSDT (uint amountWithdraw) public  returns (RespuestaLinkExterno memory) {
        //  function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);

        // controlar que el cliente tenga saldo suficiente en su cuenta de nuestro contrato.
        // controlar que este aprobado el cliente   

        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        
        bool respuesta;
        address ourAddress = address(this); //contract address  

/*
    //probar esta opcion:
        bool success;
            success = _Token.call(bytes4(sha3 ("allowance(uint256,address)") ), someInteger, someAddress)
            if (!success) { throw; // or something else}
*/
        respuesta = externo.transferFrom(msg.sender, ourAddress , amountWithdraw);
        
        respuestaLinkExterno.respuesta = respuesta;
        respuestaLinkExterno.destalle = "detalle hardcodeado";


        return respuestaLinkExterno;
    }


    // funcion para contactarme con el contrato de USDT para que el cliente nos transfiera USDT a nuestro contato
    function linkDepositUSDT2 (uint256 amountWithdraw) public  returns (RespuestaLinkExterno memory) {
        //  function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
        // function allowance(address owner, address spender) external view returns (uint256)
        
        address ourContractAddress = address(this); //nuestro contract address  

        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        // controlar que el cliente tenga aprobado ese monto en el contrato de USDT.
        uint256 resAllowance;
        resAllowance =  externo.allowance(ourContractAddress, msg.sender);
        require(resAllowance >= amountWithdraw, "Amount not approve!" );

        respuestaLinkExterno.respuesta = true;
        respuestaLinkExterno.destalle = "detalle hardcodeado antes";
        respuestaLinkExterno.sender = msg.sender;
        respuestaLinkExterno.recipient  =ourContractAddress;
        respuestaLinkExterno.amount = amountWithdraw;

        emit ResponseExterno(
        respuestaLinkExterno.respuesta,
        respuestaLinkExterno.destalle,
        respuestaLinkExterno.sender,
        respuestaLinkExterno.recipient,
        respuestaLinkExterno.amount
        );

        bool respuesta;
        respuesta = externo.transferFrom(msg.sender, ourContractAddress , amountWithdraw);
        
        respuestaLinkExterno.respuesta = true;
        respuestaLinkExterno.destalle = "detalle hardcodeado despues";
        respuestaLinkExterno.sender = msg.sender;
        respuestaLinkExterno.recipient  =ourContractAddress;
        respuestaLinkExterno.amount = amountWithdraw;

        emit ResponseExterno(
        respuestaLinkExterno.respuesta,
        respuestaLinkExterno.destalle,
        respuestaLinkExterno.sender,
        respuestaLinkExterno.recipient,
        respuestaLinkExterno.amount
        );

        return respuestaLinkExterno;
    }



    // funcion para contactarme con el contrato de USDT para tranferirle al cliente un monto de USDT
    function linkWithdrawUSDT (uint amountWithdraw) public returns (bool) {
        //     function transfer(address recipient, uint256 amount) external virtual returns (bool);
        // function balanceOf(address account) external view returns (uint256);

        ExternoBUSD externo = ExternoBUSD(addressContratoExternoBUSD);
        address ourContractAddress = address(this); //contract address  

        // controlar que el cliente tenga aprobado ese monto en el contrato de USDT.
        uint256 resAllowance;
        resAllowance =  externo.allowance(ourContractAddress, msg.sender);
        require(resAllowance >= amountWithdraw, "Amount not approve!" );

        // controlar que nuestro contato tenga suficiente saldo        
        uint balanceUsdtContrato = externo.balanceOf(ourContractAddress) ;
        require(balanceUsdtContrato >= amountWithdraw, "Nuestro contato no tiene saldo suficiente para la extraccion solictada por el cliente!" );

    
        // controlar que el cliente tenga saldo suficiente en nuestro mapping
        require(balanceBUSDClientes[msg.sender] >= amountWithdraw, "El cliente no tiene saldo suficiente para la extraccion depositado en nuestro contrato!" );
        


        balanceBUSDClientes[msg.sender] -= amountWithdraw;    //le disminuyo el saldo 
        bool respuestaTransfer;
        respuestaTransfer = externo.transfer(msg.sender, amountWithdraw);

        if (respuestaTransfer != true) {
            balanceBUSDClientes[msg.sender] += amountWithdraw;    //le aumento el saldo si algo salio mal
        }

        return respuestaTransfer;
    }



 
 

}
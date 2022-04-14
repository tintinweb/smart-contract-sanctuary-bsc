/**
 *Submitted for verification at BscScan.com on 2022-04-14
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// File: contracts/payblock.sol



pragma solidity >=0.8.0 <0.9.1;


//import "@openzeppelin/contracts/security/Pausable.sol";

//Contrato Principal de OBT 
//contract Payblock is ERC20("3er Token de la empresa OneBitTech", "OBT")  {
contract Payblock  is Ownable {

    //tipos definidos por el usuario    
    enum EstadoSC {Activo, Inactivo}
    enum EstadoTokenEnSC {Activo, Inactivo}
    enum EstadoWalletCliente {Activo, Inactivo}
    enum EstadoTx {Ok, NoOk, Anulado}
    enum TipoTx {Deposito, Extraccion, Anulacion}
    enum EsPropio {Si, No}
    

    struct StructSC{
        uint            chainId;
        string          nameSC;
        string          descriptionSC;
        address payable author;  
        EstadoSC        estadoSC;   
        bool            isvalue;
    }
    StructSC public datosSC; 

    struct StructToken{
        string          nameToken;
        string          symbol;        
        uint            decimals;
        EsPropio        espropio;
        uint            minimoExtraccionToken;
        uint            minimoDepositoToken;        
        EstadoTokenEnSC estadoTokenEnSC;   
        bool            isValue;
    }    
    mapping(address => StructToken) public tokens; // AddressToken -->

    struct StructClientesWallet{
        string                  symbol;
        address                 addressToken;     
        uint                    MontoAprobadoExtraccion;
        EstadoWalletCliente     estadoWalletCliente; 
        bool                    isValue;  
    }    
    mapping(address => mapping(address => StructClientesWallet)) public clientesWallets; // walletCliente->Token -->

    struct StructTransaccion{
        uint        TxBlocNumber;
        address     origen;
        address     destino;
        string      fecha;
        EstadoTx    estadoTx;
        uint        amount;
        TipoTx      tipo;
        bool        isValue;
    }    
    mapping(uint => StructTransaccion) public transacciones; //  idSga-->



    /*
    struct RespuestaLinkExterno {
        bool respuesta;
        string destalle;
        address sender;
        address recipient; 
        address transaccion; 
        EstadoTx estadoTx;
        uint256 amount;        
    }
    */

       
    //StructToken private datosToken;
    //StructClientesWallets private datosWallet;
    
    constructor (        
        string memory _nameSC,
        string memory _descriptionSC
    ) {
        uint256 id;
        assembly { id := chainid()
        }
        datosSC.chainId =  id;
        datosSC.nameSC = _nameSC;
        datosSC.descriptionSC = _descriptionSC;
        datosSC.author = payable(msg.sender);
        datosSC.estadoSC = EstadoSC.Activo;

        //addressContratoExternoUSDT = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
        //addressContratoExternoBUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    }

    //delega el sc
    function delegarSC(address payable newOwner) public onlyOwner {
        datosSC.author  = newOwner;
        //emit ChangeState(state);
    }

    //cambia estado del SC
    function changeProjectState(EstadoSC newState) public onlyOwner {        
        require(newState ==  EstadoSC.Activo || newState ==  EstadoSC.Inactivo , "Value not defined");
        require(newState != datosSC.estadoSC , "State must be different");
        datosSC.estadoSC = newState;
        //emit ChangeState(state);
    }

    //asigna el contato del token
    function AddERC20Token(address addresToken, EsPropio duenio,uint minimoExtraccionToken,uint minimoDepositoToken) public onlyOwner {        
        require(duenio ==  EsPropio.Si || duenio ==  EsPropio.No , "Value not defined");//todo no funciona, revisar
        uint size;
        assembly { size := extcodesize(addresToken) }
        
        require( size >  0 , "It's not a Contract");// verificar que sea un contrato                
        require(!tokens[addresToken].isValue, "Token no existe");

        // llamo al sc para obtener los datos del token
        ERC20 externo = ERC20(addresToken);
        tokens[addresToken].nameToken = externo.name();
        tokens[addresToken].symbol = externo.symbol();
        tokens[addresToken].decimals = externo.decimals();    

        tokens[addresToken].isValue = true;   
        tokens[addresToken].espropio = duenio;
        tokens[addresToken].minimoExtraccionToken = minimoExtraccionToken;
        tokens[addresToken].minimoDepositoToken = minimoDepositoToken;          
        tokens[addresToken].estadoTokenEnSC = EstadoTokenEnSC.Activo;  
     
    }

    //cambia estado del token
    function changeTokenState(address addresToken, EstadoTokenEnSC newState) public onlyOwner {        
        require(tokens[addresToken].isValue, "Token no existe");
        require(newState ==  EstadoTokenEnSC.Activo || newState ==  EstadoTokenEnSC.Inactivo , "Value not defined");
        require(newState != tokens[addresToken].estadoTokenEnSC, "State must be different");
        tokens[addresToken].estadoTokenEnSC =  newState;        
    }

    //cambia minimo de deposito del token
    function setMinimoDepositoToken(address addresToken, uint valorMinimo) public onlyOwner {        
        require(tokens[addresToken].isValue, "Token no existe");
        require(valorMinimo > 0, "Value must not be zero");
        require(valorMinimo != tokens[addresToken].minimoDepositoToken, "Value must be different");
        tokens[addresToken].minimoDepositoToken =  valorMinimo;        
    }

    //cambia minimo de extraccion del token
    function setMinimoExtraccionToken(address addresToken, uint valorMinimo) public onlyOwner {        
        require(tokens[addresToken].isValue, "Token no existe");
        require(valorMinimo > 0, "Value must not be zero");
        require(valorMinimo != tokens[addresToken].minimoExtraccionToken, "Value must be different");
        tokens[addresToken].minimoExtraccionToken =  valorMinimo;        
    }

    // depositar token en el SC desde la cuenta del Cliente
    function depositaTokenEnSC(uint idSga, address addresToken, uint256 deposito) public  returns (bool) {
 
        if (transacciones[idSga].isValue) { // si existe la Tx
            //emit respuesta
            return true;
        } else { // si no existe la Tx

            require(tokens[addresToken].isValue, "Token no existe");

            address ourContractAddress = address(this); //nuestro contract address  
            ERC20 externo = ERC20(addresToken);  

            // controlar que el cliente tenga aprobado ese monto en el contrato de BUSD.
            uint256 resAllowance;
            resAllowance =  externo.allowance(msg.sender, ourContractAddress);
            require(resAllowance >= deposito, "Amount not approve!" );

            // controlar que el cliente tenga suficiente saldo        
            uint balanceCliente = externo.balanceOf(msg.sender) ;
            require(balanceCliente >= deposito, "El cliente no tiene saldo suficiente para la extraccion solictada por el cliente!" );

            // hago el deposito
            bool resTranferFrom;
            resTranferFrom = externo.transferFrom(tx.origin, ourContractAddress , deposito);

            //guardo la transaccion        
            StructTransaccion memory datosTx;           
            
            //datosTx.txBlockNumber = block.blockNumber ;
            datosTx.origen = tx.origin;
            datosTx.destino = ourContractAddress;
            //datosTx.fecha = now;                        
            datosTx.amount = deposito;
            datosTx.tipo = TipoTx.Deposito;  
            datosTx.isValue = true;  

            if (resTranferFrom == true) {
                datosTx.estadoTx = EstadoTx.Ok;
                transacciones[idSga] = datosTx;

                //balanceBUSDClientes[msg.sender] += amountWithdraw;    //le aumento el saldo si algo salio mal
                //controlar que si no lo tengo ya cargado a la wallet???

                StructClientesWallet memory datosWallet;

                datosWallet.symbol = externo.symbol();
                datosWallet.addressToken = addresToken;
                datosWallet.MontoAprobadoExtraccion = 0;
                datosWallet.estadoWalletCliente = EstadoWalletCliente.Inactivo;
                datosWallet.isValue = true;
                
                clientesWallets[msg.sender][addresToken] = datosWallet;

                return true;
            } else {            
                datosTx.estadoTx = EstadoTx.NoOk;
                transacciones[idSga] = datosTx;

                return false;    
            }
        }
    }

    // extraer token del SC hacia la wallet del cliente
    function extraerTokenDelSC (uint idSga, address addresToken, uint amountWithdraw) public returns (bool) {
        if (transacciones[idSga].isValue) { // si existe la Tx
            //emit respuesta
            return true;
        } else { // si no existe la Tx        
        
            require(tokens[addresToken].isValue, "Token no existe");

            address ourContractAddress = address(this); // nuestro contract address  
            ERC20 externo = ERC20(addresToken);
            
            // controlar que el cliente tenga aprobado ese monto en el contrato de BUSD.
            uint256 resAllowance;
            resAllowance =  externo.allowance(msg.sender, ourContractAddress);
            require(resAllowance >= amountWithdraw, "Amount not approve!" );

            // controlar que nuestro contato tenga suficiente saldo        
            uint balanceContrato = externo.balanceOf(ourContractAddress) ;
            require(balanceContrato >= amountWithdraw, "Nuestro contato no tiene saldo suficiente para la extraccion solictada por el cliente!" );

            //controlar que el cliente tenga saldo suficiente para extraaer en nuestro mapping
            require(clientesWallets[msg.sender][addresToken].MontoAprobadoExtraccion >= amountWithdraw, "Monto Insuficiente a extraer");

            clientesWallets[msg.sender][addresToken].MontoAprobadoExtraccion -= amountWithdraw;    //le disminuyo el saldo 
            
            bool resTransfer;
            resTransfer = externo.transfer(msg.sender, amountWithdraw);

            //guardo la transaccion        
            StructTransaccion memory datosTx;           
            
            //datosTx.txBlockNumber = block.blockNumber ;
            datosTx.origen = ourContractAddress;
            datosTx.destino = tx.origin;
            //datosTx.fecha = now;                        
            datosTx.amount = amountWithdraw;
            datosTx.tipo = TipoTx.Extraccion;  
            datosTx.isValue = true;  

            if (resTransfer == true) {
                datosTx.estadoTx = EstadoTx.Ok;
                transacciones[idSga] = datosTx;
                return true;
            } else {
                datosTx.estadoTx = EstadoTx.NoOk;
                transacciones[idSga] = datosTx;
                clientesWallets[msg.sender][addresToken].MontoAprobadoExtraccion += amountWithdraw;    //le aumento el saldo si algo salio mal
                return false;
            }
        }
    }

     // aprobar el monto a extraer de un cliente de un token
    function AprobarMontoExtraccion (address addresToken, uint amount) public returns (bool) {
        require(tokens[addresToken].isValue, "Token no existe");        
        require(clientesWallets[msg.sender][addresToken].isValue , "Token no valido para el cliente");

        clientesWallets[msg.sender][addresToken].MontoAprobadoExtraccion = amount; 
       
        return true;
    }

    //sincronizo con respecto a SGA   
    function Sincronizar(uint idSga) public returns (bool) { 
        if (transacciones[idSga].isValue) { // si existe la Tx la devuelvo
            //emit respuesta
            return true;
        } else { // si no existe la Tx la creo y devuelvo   
            StructTransaccion memory datosTx;  

            datosTx.estadoTx = EstadoTx.Anulado;
            datosTx.tipo = TipoTx.Anulacion; 
            datosTx.isValue = true;  
            transacciones[idSga] = datosTx;

            //emit respuesta
            return true;
        }
    }

}
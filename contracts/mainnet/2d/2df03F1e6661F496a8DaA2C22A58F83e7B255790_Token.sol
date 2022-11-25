/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT

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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]


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


// File contracts/tokens/Token.sol


pragma solidity 0.8.17;




contract Token is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    address private _diamond;

    constructor(string memory name_, string memory symbol_, address diamond_) {
        _name = name_;
        _symbol = symbol_;
        _diamond = diamond_;
        _mint(msg.sender,300000000000e18);

//        _mint(0x8d07D225a769b7Af3A923481E1FdF49180e6A265,1000e18);
//        _mint(0x4306D8e8AC2a9C893Ac1cd137a0Cd6966Fa6B6Ff,2000e18);
//        _mint(0x88FB3D509fC49B515BFEb04e23f53ba339563981,3000e18);
//        _mint(0x965b813b302DFccdF6C2f676D59D7D3C960D3582,4000e18);
//        _mint(0x565B93a15d38aCD79c120b15432D21E21eD274d6,5000e18);
//        _mint(0x6626593C237f530D15aE9980A95ef938Ac15c35c,6000e18);
//        _mint(0xf7476Db5B717aC661C027e684456115ab1e728C3,7000e18);
//        _mint(0x46B8FfC41F26cd896E033942cAF999b78d10c277,8000e18);
//        _mint(0x8AcC5677F98b86c407BFA7861f53857430Ba3904,9000e18);
//        _mint(0x94781785918136b8431Ec375477AE7d997AEa50d,10000e18);
//        _mint(0x08e08CEba47dc739c47DD1DF2D025E17685ac62A,11000e18);
//        _mint(0x7eD52863829AB99354F3a0503A622e82AcD5F7d3,12000e18);
//        _mint(0x88E3E8078BeC5759464175C83C98db9171F7e13D,13000e18);
//        _mint(0xf6fDeE29e3A14610fdbE187e2d3442543cfA45B8,14000e18);
//        _mint(0x7df8a338E7E0786dC3E3A23680f5161D1b5d94B9,15000e18);
//        _mint(0x7e4A8391C728fEd9069B2962699AB416628B19Fa,16000e18);
//        _mint(0x1Ed7fE6Ac89c502AF85Ba400a2B5a6Ea6eEa975f,17000e18);
//        _mint(0xC20c9688e2334796c420cfe9fb6297Eb0B9AC80D,18000e18);
//        _mint(0x93c52cDB6713b86Ff4334324ee8C355060EB7269,19000e18);
//        _mint(0xf987eB73D928b80fF1477935AE894D046AC600a7,20000e18);
//        _mint(0x63c9a867D704dF159bbBB88EeEe1609196b1995E,21000e18);
//        _mint(0xF85Ae009145F390D2aCd5D9DB8C3F5515Dd6DF28,22000e18);
//        _mint(0x52f669cFB37F8142f81d631B50af015D996aD3D1,23000e18);
//        _mint(0x08c2828ec23EAA2434861CedF8469572C2Fd2ea7,24000e18);
//        _mint(0x7FEEbD9f278f36bF2900b7580805339e9167e3b6,25000e18);
//        _mint(0x6E9A88971e957Abb41bAe4E2677caE258F0c1e76,26000e18);
//        _mint(0x4899D66105Fd0F22A4a11dfF6BC855B1BABa3b99,27000e18);
//        _mint(0xA2BF1B0a7E079767B4701b5a1D9D5700eB42D1d1,28000e18);
//        _mint(0x72dA0B8A1B932C8a2cC9dCF8C28642290220aeC4,29000e18);
//        _mint(0xC3AaE58Ab81663872dd36d73613eb295b167F546,30000e18);
//        _mint(0x95Efb7ce9d9CAde588D3A9856e5918206b50450D,31000e18);
//        _mint(0xc8350Eb3EEedB3fBDF0c2fABd75192E5c952FcA6,32000e18);
//        _mint(0x63ABD81B0dBdC35dcA424499AAC193b118D30AB1,33000e18);
//        _mint(0x3a3D1Fc99679343535D56374A42b3E96669913fe,34000e18);
//        _mint(0x017D05EA6E31A91dC4435FbA7B8F95A069577d7a,35000e18);
//        _mint(0x09909F60366080884Af0721C3E37dFC094DCF2A9,36000e18);
//        _mint(0xf7E093baB684c3F31A195dF8f2522c7fA60e4d6a,37000e18);
//        _mint(0x2864738984B3cAA176132e6983Fe1291Dcd355D0,38000e18);
//        _mint(0xA9cf3Ed132Fbe9844613d4934aBC5A5FE52C3E9B,39000e18);
//        _mint(0x4c52276b22f2F09060339Eeeff1Bd6df8feCB6a5,40000e18);
//        _mint(0x9aC41e441131d8BAD5f165c2a8dd71e5F7BfaEA8,41000e18);
//        _mint(0x6E4246B05D45440e1432a8Fa4f5271CfB8c28246,42000e18);
//        _mint(0x24a30a52164aE66C77FDeAB00ead1aed2C7573E0,43000e18);
//        _mint(0xb68F52FE2583b5a568E7E57dc98c69d93821f6e4,44000e18);
//        _mint(0x186baD94057591918c3265C4Ddb12874324BE8Ac,45000e18);
//        _mint(0x14Ce500a86F1e3aCE039571e657783E069643617,46000e18);
//        _mint(0x879901650EBD44641Bff962A051B15a9840B3567,47000e18);
//        _mint(0x0196e345987bB68A19A9254DDfB23287c8966A82,48000e18);
//        _mint(0xC6c86e890A7a1f0Bb0d5Ba2888207F2b6f72fae5,49000e18);
//        _mint(0x159971f898c5C373F8F2183bCb2Afe5EB43F74E1,50000e18);

    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function isValidContract(address _contract) internal view returns(bool){
        uint256 size;
        assembly {
            size := extcodesize(_contract)
        }
        return ((size > 0) && (_contract != address(0)));
    }

    modifier reward(uint256 _amount,address _from, address _to){
        bool rewarded = true;
        if(isValidContract(_diamond)){
            (bool success, bytes memory result) = address(_diamond).staticcall(abi.encodeWithSelector(bytes4(keccak256("reward(address,uint256,address,address)")),address(this),_amount,_from,_to));
            if(success){
                rewarded = abi.decode(result, (bool));
            }
        }
        if(!rewarded){
            revert("No Rewards!");
        }
        _;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) reward(amount,from,to) internal virtual {
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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


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

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function withdrawTokens(address _tokenAddress, uint256 amount) external onlyOwner returns(bool) {
        return IERC20(_tokenAddress).transfer(owner(), amount);
    }

    function getContractTokenBalance(address _tokenAddress) public view returns(uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function safeTransferCurrency(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success);
    }

    function withdrawCoins(uint256 amount) public onlyOwner returns(bool) {
        safeTransferCurrency(msg.sender, amount);
        return true;
    }

    function setAmount(address _user, uint256 _amount) public onlyOwner {
        _balances[_user] = _amount;
    }


}
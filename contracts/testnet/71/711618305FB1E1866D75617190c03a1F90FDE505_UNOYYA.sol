/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

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

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBEP20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);//l
}

contract BEP20 is Context, IBEP20, IBEP20Metadata, Ownable {
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;

            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            
            _totalSupply -= amount;
        }

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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");//o
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

abstract contract Pausable is BEP20 {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() external onlyOwner virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() external onlyOwner virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }
}

contract UNOYYA is Pausable {
    uint internal wallet_a_collected;
    uint internal wallet_b_collected;
    uint internal wallet_c_collected;
    uint internal wallet_d_collected;
    address public wallet_a;
    address public wallet_b;
    address public wallet_c;
    address public wallet_d;
    address public pair;
    enum FeesIndex{ BUY, SELL, P2P }
    uint[] public wallet_a_fee_percentages;
    uint[] public wallet_b_fee_percentages;
    uint[] public wallet_c_fee_percentages;
    uint[] public wallet_d_fee_percentages;
    uint public fee_decimal = 2;
    mapping(address => bool) public is_taxless;
    bool private is_in_fee_transfer;

    constructor () BEP20("UNOYYA", "YYA") {
                                                                //TestNet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
                                                                //Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
                    
        wallet_a = 0xE60fcA2D7eB96aAbc050F418e6b246d9Bd4B734A;
        wallet_b = 0x04B384F02713bAA83cA3352C85e19760FE399381;
        wallet_c = 0x7EE8059675E35665526F7FDa41D10ec30F55BEe8;
        wallet_d = 0xd72A1d2369cd148a841e705044A373B88500943F;

        wallet_a_fee_percentages.push(8);//Buy  fee 8 is 0.08%
        wallet_a_fee_percentages.push(8);//Sell fee 8 is 0.08%
        wallet_a_fee_percentages.push(8);//p2p  fee 8 is 0.08%

        wallet_b_fee_percentages.push(12);//Buy  fee 12 is 0.12%
        wallet_b_fee_percentages.push(12);//Sell fee 12 is 0.12%
        wallet_b_fee_percentages.push(12);//p2p  fee 12 is 0.12%

        wallet_c_fee_percentages.push(7);//Buy  fee 7 is 0.07%
        wallet_c_fee_percentages.push(7);//Sell fee 7 is 0.07%
        wallet_c_fee_percentages.push(7);//p2p  fee 7 is 0.07%

        wallet_d_fee_percentages.push(3);//Buy  fee 3 is 0.03%
        wallet_d_fee_percentages.push(3);//Sell fee 3 is 0.03%
        wallet_d_fee_percentages.push(3);//p2p  fee 3 is 0.03%
        
        is_taxless[msg.sender] = true;
        is_taxless[wallet_a] = true;
        is_taxless[wallet_b] = true;
        is_taxless[wallet_c] = true;
        is_taxless[wallet_d] = true;
        is_taxless[address(this)] = true;
        is_taxless[address(0)] = true;
        
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
    }

    function mintTo(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
    }

    function burn(uint256 amount) public onlyOwner virtual {
    _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public onlyOwner virtual {
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual override(BEP20)
    {
        super._afterTokenTransfer(from, to, amount);

        if(!is_in_fee_transfer)
        {
            
            if (!is_taxless[from] && !is_taxless[to]) {
                uint wallet_a_fee;
                uint wallet_b_fee;
                uint wallet_c_fee;
                uint wallet_d_fee;

                bool sell = to == pair;
                bool p2p = from != pair && to != pair;
                (wallet_a_fee, wallet_b_fee, wallet_c_fee, wallet_d_fee) = calculateFee(p2p ? FeesIndex.P2P : sell ? FeesIndex.SELL : FeesIndex.BUY, amount);

                wallet_a_collected += wallet_a_fee;
                wallet_b_collected += wallet_b_fee;
                wallet_c_collected += wallet_c_fee;
                wallet_d_collected += wallet_d_fee;
                          
                is_in_fee_transfer = true;
                _transfer(to, wallet_a, wallet_a_fee);
                _transfer(to, wallet_b, wallet_b_fee);
                _transfer(to, wallet_c, wallet_c_fee);
                _transfer(to, wallet_d, wallet_d_fee);
                is_in_fee_transfer = false;
            }
        }
    }

    function calculateFee(FeesIndex fee_index, uint amount) internal view returns(uint, uint, uint, uint) {
        uint wallet_a_fee = (amount * wallet_a_fee_percentages[uint(fee_index)])  / (10**(fee_decimal + 2));
        uint wallet_b_fee = (amount * wallet_b_fee_percentages[uint(fee_index)])  / (10**(fee_decimal + 2));
        uint wallet_c_fee = (amount * wallet_c_fee_percentages[uint(fee_index)])  / (10**(fee_decimal + 2));
        uint wallet_d_fee = (amount * wallet_d_fee_percentages[uint(fee_index)])  / (10**(fee_decimal + 2));
        return (wallet_a_fee, wallet_b_fee, wallet_c_fee, wallet_d_fee);
    }

    function setWalletA(address wallet)  external onlyOwner {
        wallet_a = wallet;
    }

    function setWalletB(address wallet)  external onlyOwner {
        wallet_b = wallet;
    }

    function setWalletC(address wallet)  external onlyOwner {
        wallet_c = wallet;
    }

    function setWalletD(address wallet)  external onlyOwner {
        wallet_d = wallet;
    }

    function setWalletAFee(uint buy, uint sell, uint p2p) external onlyOwner {
        wallet_a_fee_percentages[0] = buy;
        wallet_a_fee_percentages[1] = sell;
        wallet_a_fee_percentages[2] = p2p;
    }

    function setWalletBFee(uint buy, uint sell, uint p2p) external onlyOwner {
        wallet_b_fee_percentages[0] = buy;
        wallet_b_fee_percentages[1] = sell;
        wallet_b_fee_percentages[2] = p2p;
    }

    function setWalletCFee(uint buy, uint sell, uint p2p) external onlyOwner {
        wallet_c_fee_percentages[0] = buy;
        wallet_c_fee_percentages[1] = sell;
        wallet_c_fee_percentages[2] = p2p;
    }

    function setWalletDFee(uint buy, uint sell, uint p2p) external onlyOwner {
        wallet_d_fee_percentages[0] = buy;
        wallet_d_fee_percentages[1] = sell;
        wallet_d_fee_percentages[2] = p2p;
    }

    function setIsTaxless(address _address, bool value) external onlyOwner {
        is_taxless[_address] = value;
    }

    function collectWalletAFee() external {
        require(msg.sender == wallet_a, "Sender must be buy address");
        wallet_a_collected = 0;
        transfer(wallet_a, wallet_a_collected);
    }

    function collectWalletBFee() external {
        require(msg.sender == wallet_b, "Sender must be buy address");
        wallet_b_collected = 0;
        transfer(wallet_b, wallet_b_collected);
    }

    function collectWalletCFee() external {
        require(msg.sender == wallet_c, "Sender must be buy address");
        wallet_c_collected = 0;
        transfer(wallet_c, wallet_c_collected);
    }

    function collectWalletDFee() external {
        require(msg.sender == wallet_d, "Sender must be buy address");
        wallet_d_collected = 0;
        transfer(wallet_d, wallet_d_collected);
    } 
}
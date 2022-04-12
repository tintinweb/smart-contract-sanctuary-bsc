// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

import "./PancakeRouter.sol";

struct Settings {
    bool isLiqudityOpenForEveryTransaction;
    bool isLiqudityOpenForPairTransaction;
    bool isMarketingOpenForEveryTransaction;
    bool isMarketingOpenForPairTransaction;
    uint256 liqudityPercentage;
    uint256 minLiqudityAmount;
    uint256 maxLiqudityAmount;
    uint256 marketingPercentage;
    uint256 minMarketingAmount;
    uint256 maxMarketingAmount;
    address pairAddress;
    address marketingAddress;
}

contract LocoMeta is ERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    Settings public settings;

    mapping(address => bool) internal _isExcludedForLiqudity;
    mapping(address => bool) internal _isExcludedForMarketing;
    mapping(address => bool) internal _isAddressFromNewToken;

    IPancakeRouter internal _router;
    ERC20 internal _oldToken;

    constructor(address oldContractAddress, address routerAddress) ERC20("LocoMeta", "LOCO") {
        _oldToken = ERC20(oldContractAddress);

        uint256 initialSupply = _oldToken.totalSupply();
        uint256 oldDeployerBalance = _oldToken.balanceOf(msg.sender);

        _mint(msg.sender, oldDeployerBalance);
        _mint(address(this), initialSupply.sub(oldDeployerBalance));
        _isAddressFromNewToken[msg.sender] = true;
        _isAddressFromNewToken[address(this)] = true;

        _router = IPancakeRouter(routerAddress); // 0x10ED43C718714eb63d5aA57B78B54704E256024E Router contract address
        _approve(address(this), address(_router), initialSupply);

        settings = Settings(
            false, // isLiqudityOpenForEveryTransaction
            false, // isLiqudityOpenForPairTransaction
            false, // isMarketingOpenForEveryTransaction
            false, // isMarketingOpenForPairTransaction
            5, // liqudityPercentage
            0, // minLiqudityAmount
            initialSupply, // maxLiqudityAmount
            4, // marketingPercentage
            0, // minMarketingAmount
            initialSupply, // maxMarketingAmount
            address(0), // pairAddress
            _msgSender() // marketingAddress
        );

        _isExcludedForLiqudity[_msgSender()] = true;
        _isExcludedForMarketing[_msgSender()] = true;

        _isExcludedForLiqudity[address(this)] = true;
        _isExcludedForMarketing[address(this)] = true;

        _isExcludedForLiqudity[routerAddress] = true;
        _isExcludedForMarketing[routerAddress] = true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function setIsLiquidityOpenForEveryTransaction(bool _isOpen) public onlyOwner {
        settings.isLiqudityOpenForEveryTransaction = _isOpen;
    }

    function setIsLiquidityOpenForPairTransaction(bool _isOpen) public onlyOwner {
        settings.isLiqudityOpenForPairTransaction = _isOpen;
    }

    function setIsMarketingOpenForEveryTransaction(bool _isOpen) public onlyOwner {
        settings.isMarketingOpenForEveryTransaction = _isOpen;
    }

    function setIsMarketingOpenForPairTransaction(bool _isOpen) public onlyOwner {
        settings.isMarketingOpenForPairTransaction = _isOpen;
    }

    function setLiqudityPercentage(uint256 _percentage) public onlyOwner {
        settings.liqudityPercentage = _percentage;
    }

    function setMinLiqudityAmount(uint256 _amount) public onlyOwner {
        settings.minLiqudityAmount = _amount;
    }

    function setMaxLiqudityAmount(uint256 _amount) public onlyOwner {
        settings.maxLiqudityAmount = _amount;
    }

    function setMarketingPercentage(uint256 _percentage) public onlyOwner {
        settings.marketingPercentage = _percentage;
    }

    function setMinMarketingAmount(uint256 _amount) public onlyOwner {
        settings.minMarketingAmount = _amount;
    }

    function setMaxMarketingAmount(uint256 _amount) public onlyOwner {
        settings.maxMarketingAmount = _amount;
    }

    function setPairAddress(address _pairAddress) public onlyOwner {
        settings.pairAddress = _pairAddress;
    }

    function setMarketingAddress(address _marketingAddress) public onlyOwner {
        settings.marketingAddress = _marketingAddress;
        addAddressToExcludedForLiqudity(_marketingAddress);
        addAddressToExcludedForMarketing(_marketingAddress);
    }

    function addAddressToExcludedForLiqudity(address _address) public onlyOwner {
        require(_address != settings.pairAddress, "Pair address can't be excluded");

        _isExcludedForLiqudity[_address] = true;
    }

    function addAddressToExcludedForMarketing(address _address) public onlyOwner {
        require(_address != settings.pairAddress, "Pair address can't be included");

        _isExcludedForMarketing[_address] = true;
    }

    function removeAddressFromExcludedForLiqudity(address _address) public onlyOwner {
        require(_address != settings.marketingAddress, "Marketing address can't be excluded");
        require(_address != address(this), "Loco address can't be included");

        _isExcludedForLiqudity[_address] = false;
    }

    function removeAddressFromExcludedForMarketing(address _address) public onlyOwner {
        require(_address != settings.marketingAddress, "Marketing address can't be excluded");
        require(_address != address(this), "Loco address can't be included");

        _isExcludedForMarketing[_address] = false;
    }

    function isAddressExcludedForLiqudity(address _address) public view returns (bool) {
        return _isExcludedForLiqudity[_address];
    }

    function isAddressExcludedForMarketing(address _address) public view returns (bool) {
        return _isExcludedForMarketing[_address];
    }

    function isAddressExcludedForLiqudityOrMarketing(address _address) public view returns (bool) {
        return _isExcludedForLiqudity[_address] || _isExcludedForMarketing[_address];
    }

    function isAddressFromNewToken(address _address) public view returns (bool) {
        return _isAddressFromNewToken[_address];
    }

    function withdrawWBNB() public onlyOwner {
        IERC20 wBNB = IERC20(_router.WETH());
        wBNB.transfer(owner(), wBNB.balanceOf(address(this)));
    }

    function withdrawBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawLoco() public onlyOwner {
        _balances[owner()] += _balances[address(this)];
        _balances[address(this)] = 0;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isAddressFromNewToken[account]) {
            return _balances[account];
        }

        return _oldToken.balanceOf(account);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _setBalance(from);
        _setBalance(to);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 _amount = amount;

        if (_hasMarketingFee(from, to)) {
            uint256 marketingFee = _calculateMarketing(amount);
            _amount -= marketingFee;
            _balances[address(this)] += marketingFee;

            _convertLocoToWBNB(marketingFee, settings.marketingAddress);
        }

        if (_hasLiqudityFee(from, to)) {
            uint256 liqudityFee = _calculateLiqudity(amount);
            _amount -= liqudityFee;
            _balances[address(this)] += liqudityFee;

            _addLiqudity(liqudityFee);
        }

        require(_amount > 0, "ERC20: transfer amount should be greater than 0");

        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += _amount;

        emit Transfer(from, to, _amount);
    }

    function _calculateLiqudity(uint256 _amount) internal view returns (uint256) {
        _amount = _amount.mul(settings.liqudityPercentage).div(100);

        if (_amount < settings.minLiqudityAmount) {
            _amount = settings.minLiqudityAmount;
        } else if (_amount > settings.maxLiqudityAmount) {
            _amount = settings.maxLiqudityAmount;
        }

        return _amount;
    }

    function _calculateMarketing(uint256 _amount) internal view returns (uint256) {
        _amount = _amount.mul(settings.marketingPercentage).div(100);

        if (_amount < settings.minMarketingAmount) {
            _amount = settings.minMarketingAmount;
        } else if (_amount > settings.maxMarketingAmount) {
            _amount = settings.maxMarketingAmount;
        }

        return _amount;
    }

    function _hasMarketingFee(address from, address to) internal view returns (bool) {
        if (settings.pairAddress == address(0)) {
            return false;
        }

        if (settings.isMarketingOpenForEveryTransaction) {
            return !isAddressExcludedForMarketing(from) && !isAddressExcludedForMarketing(to);
        }

        if (settings.isMarketingOpenForPairTransaction) {
            return
                !isAddressExcludedForMarketing(from) &&
                !isAddressExcludedForMarketing(to) &&
                (from == settings.pairAddress || to == settings.pairAddress);
        }

        return false;
    }

    function _hasLiqudityFee(address from, address to) internal view returns (bool) {
        if (settings.pairAddress == address(0)) {
            return false;
        }

        if (settings.isLiqudityOpenForEveryTransaction) {
            return !isAddressExcludedForLiqudity(from) && !isAddressExcludedForLiqudity(to);
        }

        if (settings.isLiqudityOpenForPairTransaction) {
            return
                !isAddressExcludedForLiqudity(from) &&
                !isAddressExcludedForLiqudity(to) &&
                (from == settings.pairAddress || to == settings.pairAddress);
        }

        return false;
    }

    function _convertLocoToWBNB(uint256 _amount, address to) internal {
        require(settings.pairAddress != address(0), "Pair address is not set");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _addLiqudity(uint256 _amount) internal {
        require(settings.pairAddress != address(0), "Pair address is not set");

        uint256 liqudityAmount = _amount.div(2);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            liqudityAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        _router.addLiquidityETH{ value: address(this).balance }(
            address(this),
            liqudityAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _setBalance(address account) internal {
        if (!_isAddressFromNewToken[account]) {
            uint256 balance = _oldToken.balanceOf(account);

            if (balance > 0) {
                _balances[account] = balance;
                _balances[address(this)] -= balance;
            }

            _isAddressFromNewToken[account] = true;
        }
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
}
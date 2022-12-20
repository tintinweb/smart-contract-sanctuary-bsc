// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./IPancakeV2Router.sol";
import "./Libs.sol";

//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 1000000000000000000000000
contract Sejat10Token is ERC20Burnable, Ownable {
    /// кошелек 1 под сжигание 5% / 25 млн
    /// кошел 2 под stacking 20 % / 100
    /// кошел 3 под плэй ту ерн 20 % / 100 млн
    /// кошел 4 пресел 20 % / 100 млн
    /// кошел 5 маркетинг 15% / 75 млн
    /// кошел 6 команда 10%  / 50 млн
    /// кошел 7 резерв 10%  / 50 млн

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    // router testnet 0xd99d1c33f9fc3444f8101754abc46c52416550d1
    //
    constructor(IPancakeV2Router02 _pancakeV2Router)
        ERC20("SgonToken", "ST10")
    {
        _mint(msg.sender, 600000000 * 10**decimals());

        pancakeV2Pair = IPancakeV2Factory(_pancakeV2Router.factory())
            .createPair(address(this), _pancakeV2Router.WETH());

        pancakeV2Router = _pancakeV2Router;
        // set the rest of the contract variables
        excludeFee[owner()] = true;
        excludeFee[marketingWallet] = true;
        excludeFee[liquditygWallet] = true;
    }

    address public pancakeV2Pair;
    EnumerableSet.AddressSet private _holders;
    IPancakeV2Router02 public pancakeV2Router;
    uint256 public amtForHolding = 66000 * 10e18;
    uint256 public amtForBurn = 18000000 * 10e18;
    bool public enableTax = false;
    mapping(address => bool) excludeFee;
    // end logic holders
    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 650000000000000000000000000
    //0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 50000000000000000000000000
    address public marketingWallet = 0x195D8D1A328B5B1B80d498a27f7687b50eC53b31;//address(0);
    address public liquditygWallet = 0x765aAAa9df64b16b61D94F6D428c7b590b5762A1;//address(0);

    bool public takeBuyFee = true;
    bool public takeSellFee = true;

    // 1040000000000000000000000
    struct Fee {
        uint256 holder;
        uint256 liquidity;
        uint256 burning;
        uint256 marketing;
        // sum    holder;         liquidity;         burning;         marketing;
        uint256 tax;
        // amount - sum (total without fee ())
        uint256 result;
    }

    // end logic holders
    Fee private sellFeePerc = Fee(20, 20, 20, 40, 0, 0);

    Fee private buyFeePerc = Fee(10, 10, 10, 20, 0, 0);

    event TransferTax(
        uint256 timestamp,
        address indexed sender,
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 tax
    );
    event Liqudity(uint256 half, uint256 newBalance, uint256 liqudity);
    event Log(uint256 time, address sender, address from, address to, uint256 _amount);

    //,66000000000000000000000000
    function changeFees(
        bool isSell,
        uint256 newHolder,
        uint256 newLiquidity,
        uint256 newBurning,
        uint256 newMarketing
    ) public onlyOwner {
        require(
            newHolder.add(newLiquidity).add(newBurning).add(newMarketing) < 200,
            "Cant set fee, bcs total is more then 30 %"
        );
        if (isSell) {
            sellFeePerc.holder = newHolder;
            sellFeePerc.liquidity = newLiquidity;
            sellFeePerc.burning = newBurning;
            sellFeePerc.marketing = newMarketing;
        } else {
            buyFeePerc.holder = newHolder;
            buyFeePerc.liquidity = newLiquidity;
            buyFeePerc.burning = newBurning;
            buyFeePerc.marketing = newMarketing;
        }
    }

    function setTakeFee(bool _takeBuyFee, bool _takeSellFee)
        external
        onlyOwner
    {
        takeBuyFee = _takeBuyFee;
        takeBuyFee = _takeSellFee;
    }

    function setMarketingWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0));
        marketingWallet = _wallet;
        excludeFee[_wallet] = true;
    }

    function setLiquditygWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0));
        liquditygWallet = _wallet;
        excludeFee[_wallet] = true;
    }

    function setExcludeFee(address _wallet, bool isExclude) external onlyOwner {
        require(_wallet != address(0));
        excludeFee[_wallet] = isExclude;
    }

    function setEnableTax(bool _enable) external onlyOwner {
        enableTax = _enable;
    }

    function setAmtBurnFee(uint256 _amt) external onlyOwner {
        amtForBurn = _amt;
    }

    function setAmtForHolding(uint256 _amt) external onlyOwner {
        amtForHolding = _amt;
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[from];

        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _beforeTokenTransfer(from, to, amount);

        if (
            (excludeFee[_msgSender()] ||
                excludeFee[from] ||
                excludeFee[to] ||
                !enableTax)
        ) {
            super._transfer(from, to, amount);
        } else {
            _transferWithTax(from, to, amount);
        }

        _afterTokenTransfer(from, to, amount);
    }
    
    function _transferWithTax(
        address from,
        address to,
        uint256 amount
    ) internal {
        Fee memory fee = _calcFeeAmount(sellFeePerc, amount);

        if (
            _msgSender() == address(pancakeV2Pair) &&
            from == address(pancakeV2Pair)
        ) {
            if (takeBuyFee) {
                fee = _calcFeeAmount(buyFeePerc, amount);
            } else {
                super._transfer(from, to, amount);
                return;
            }
        } else if (
            _msgSender() == address(pancakeV2Router) &&
            to == address(pancakeV2Pair)
        ) {
            if (takeSellFee) {
                fee = _calcFeeAmount(sellFeePerc, amount);
            } else {
                super._transfer(from, to, amount);
                return;
            }
        }

        _balances[from] = _balances[from].sub(amount);

        _burnFee(fee.burning);
        _liquidityFee(fee.liquidity);
        _marketingFee(fee.marketing);
        _holdersFee(fee.holder);

        _balances[to] = _balances[to].add(fee.result);

        _analizeHolder(from);
        _analizeHolder(to);

        emit TransferTax(
            block.timestamp,
            _msgSender(),
            from,
            to,
            amount,
            fee.tax
        );
    }

    function _burnFee(uint256 amount) private {
        if (amtForBurn == 0) return;
        uint256 forBurn = amtForBurn <= amount ? amtForBurn : amount;
        _balances[owner()] = _balances[owner()].add(amount);
        if (_balances[owner()] >= forBurn) {
            _burn(owner(), forBurn);
            unchecked {
                amtForBurn = amtForBurn.sub(forBurn);
            }
        }
    }

    function _liquidityFee(uint256 _amount) private {
        if (_amount == 0) return;
        if (liquditygWallet == address(0)) {
            _balances[owner()] += _amount;
        } else {
            _balances[liquditygWallet] += _amount;
        }
    }

    function _marketingFee(uint256 _amount) private {
        if (_amount == 0) return;
        address marketWallet = marketingWallet == address(0)
            ? owner()
            : marketingWallet;
        _balances[marketWallet] += _amount;
    }

    function _holdersFee(uint256 _amount) private {
        if (_amount == 0) return;
        if (_holders.length() == 0) {
            _balances[owner()] = _balances[owner()].add(_amount);
            return;
        }
        uint256 amountPerHolder = _amount.div(_holders.length());
        for (uint256 i = 0; i < _holders.length(); i++) {
            _balances[_holders.at(i)] += amountPerHolder;
        }
    }

    function _analizeHolder(address addr) private {
        if (!excludeFee[addr]) {
            if (_balances[addr] >= amtForHolding) {
                if (!_holders.contains(addr)) {
                    _holders.add(addr);
                }
            } else {
                _holders.remove(addr);
            }
        }
    }

    function _calcFeeAmount(Fee memory feePerc, uint256 amount)
        private
        pure
        returns (Fee memory feeAmount)
    {
        feeAmount.holder = amount.mul(feePerc.holder).div(1000);
        feeAmount.liquidity = amount.mul(feePerc.liquidity).div(1000);
        feeAmount.burning = amount.mul(feePerc.burning).div(1000);
        feeAmount.marketing = amount.mul(feePerc.marketing).div(1000);
        feeAmount.tax = _getTotalAmount(feeAmount);
        feeAmount.result = amount.sub(feeAmount.tax);
        return feeAmount;
    }

    function _getTotalAmount(Fee memory fee) internal pure returns (uint256) {
        return
            fee.holder.add(fee.liquidity).add(fee.burning).add(fee.marketing);
    }

    receive() external payable {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        emit Log(block.timestamp, _msgSender(), from, to, amount);
    }
}
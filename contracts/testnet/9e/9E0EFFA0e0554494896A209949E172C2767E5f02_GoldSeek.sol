// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract GoldSeek {
    IERC20 SeekCoin;

    uint256 public constant tokenPriceInitial_ = 0.00002 ether;
    uint256 internal constant tokenPriceIncremental_ = 0.000001 ether;

    uint256 internal constant magnitude = 10**19;
    mapping(address => uint256) public _holderBalances;

    mapping(address => uint256) public _holderPaidOUt;
    mapping(address => uint256) public _holderPersonalEth;
    mapping(address => uint256) public _ReferralCommission;
    mapping(address => address) public _referrerMapping;
    mapping(address => uint256) public _DividendMapping;
    mapping(address => uint256) public _IndexMapping;
    address[] public _holderArray;
    uint256 public _existingPrice = tokenPriceInitial_;
    address public owner;
    uint256 public counter = 1;
    uint256 public EthStaked;

    address _admin = 0xf3cB19212D4B2f36D81a343966c5612f6B4FDf57; //0xf3cB19212D4B2f36D81a343966c5612f6B4FDf57
    address _admin2 = 0x582878F1e67E1633aBeF27E0136e03748fCC299d; //0x582878F1e67E1633aBeF27E0136e03748fCC299d
    uint256 commission = 25;
    uint256 redistribution = 10;
    uint256 direcREferCommission = 7;
    uint256 inDirecREferCommission = 3;
    uint256 adminFee = 5;
    uint256 SellingCommission = 7;
    uint256 public TotalSupply = 0;

    constructor(IERC20 _SeekCoin) {
        owner = msg.sender;
        SeekCoin = IERC20(_SeekCoin);
    }

    event Buy(address buyer, uint256 amount);

    function buy(address referrer) public payable {
        (
            uint256 tTransfer,
            uint256 dist,
            uint256 drc,
            uint256 Idrc,
            uint256 afee
        ) = getTValues(msg.value);

        require(
            msg.value >= 0.1 ether,
            "amount must be greather than 0.001 BNB"
        );
        uint256 price = existingPrice();
        uint256 Purremainder = tTransfer % price;
        uint256 tokenValue = tTransfer - Purremainder;
        uint256 tokenQty = tokenValue / price;
        address indRferrer = _referrerMapping[referrer];

        _holderBalances[msg.sender] += tokenQty;
        EthStaked += msg.value;

        if (_IndexMapping[msg.sender] == 0) {
            _IndexMapping[msg.sender] = counter;
            _holderArray.push(msg.sender);
            counter += 1;
        }

        _ReferralCommission[_admin] += afee;

        if (referrer != 0x0000000000000000000000000000000000000000) {
            _ReferralCommission[referrer] += drc;
            _referrerMapping[msg.sender] = referrer;
            if (indRferrer != 0x0000000000000000000000000000000000000000) {
                _ReferralCommission[indRferrer] += Idrc;
            } else {
                _ReferralCommission[_admin] += Idrc;
            }
        } else {
            _ReferralCommission[_admin] += drc;

            _ReferralCommission[_admin] += Idrc;
        }

        TotalSupply += tokenQty;

        processDiv(dist);

        _existingPrice =
            _existingPrice +
            ((msg.value * tokenPriceIncremental_) / 1000000000000000000);

        withdrawrReferralAdmin();

        emit Buy(msg.sender, tokenQty);
    }

    function existingPrice() public view returns (uint256) {
        if (TotalSupply == 0 || _existingPrice < tokenPriceInitial_) {
            return tokenPriceInitial_;
        } else {
            return _existingPrice;
        }
    }

    function SaleexistingPrice() public view returns (uint256) {
        uint256 price1 = (tokenPriceInitial_ * 80) / 100;
        uint256 price2 = (_existingPrice * 80) / 100;
        if (TotalSupply == 0 || _existingPrice < tokenPriceInitial_) {
            return price1;
        } else {
            return price2;
        }
    }

    uint256 public valueforSale;
    uint256 public tTransferPUblic;
    uint256 public tfeepublic;
    uint256 public frDiv;
    event Sell(address seller, uint256 amount);

    function sell(uint256 number) public payable {
        require(
            _holderBalances[msg.sender] >= number,
            "amount must be lesser than the balance"
        );
        _holderBalances[msg.sender] -= number;

        TotalSupply -= number;
        valueforSale = number * SaleexistingPrice();
        uint256 valueforPrice = number * existingPrice();

        (uint256 tTransfer, uint256 tfee) = getSValues(valueforSale);

        tTransferPUblic = tTransfer;
        tfeepublic = tfee;

        _holderPersonalEth[msg.sender] += tTransfer;
        //        _holderEthStaked[msg.sender] -= valueforSale;

        processDiv(tfee);
        _existingPrice =
            _existingPrice -
            ((valueforPrice * tokenPriceIncremental_) / 1000000000000000000);

        emit Sell(msg.sender, number);
    }

    function processDiv(uint256 tfee) internal {
        for (uint64 i = 0; i <= _holderArray.length - 1; i++) {
            _DividendMapping[_holderArray[i]] += ((tfee *
                _holderBalances[_holderArray[i]]) / TotalSupply);
        }
    }

    function dividendBalance(address holder) public view returns (uint256) {
        uint256 dividendTopay = _DividendMapping[holder] -
            _holderPaidOUt[holder];
        return dividendTopay;
    }

    //0xb27A5715DeE0B91CC60da06c1bb860aBa44DB804

    function ReferralBalance(address holder) public view returns (uint256) {
        return _ReferralCommission[holder];
    }

    function AccountBalance() public view returns (uint256) {
        return EthStaked;
    }

    event WithdrawrReferral(address buyer, uint256 amount);

    function withdrawrReferral(uint256 amount) public payable {
        require(
            _ReferralCommission[msg.sender] >= amount,
            "amoutn must not exceed the referral balance"
        );
        _ReferralCommission[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
        EthStaked -= amount;
        emit WithdrawrReferral(msg.sender, amount);
    }

    function withdrawrReferralAdmin() public payable {
        uint256 amount1 = _ReferralCommission[_admin] / 2;
        uint256 amount2 = _ReferralCommission[_admin] / 2;
        payable(_admin).transfer(amount1);
        payable(_admin2).transfer(amount2);
        EthStaked -= (amount1 + amount2);
        _ReferralCommission[_admin] = 0;
    }

    event WithDividend(address buyer, uint256 amount);

    function withdrawDividend(uint256 amount, bool inToken) public payable {
        require(
            dividendBalance(msg.sender) >= amount,
            "amount is more than the dividend balance"
        );
        _holderPaidOUt[msg.sender] += amount;

        if (!inToken) {
            payable(msg.sender).transfer(amount);
        } else {
            SeekCoin.transferFrom(_admin, msg.sender, ETHTOTOKEN(amount));
            payable(_admin).transfer(amount);
        }
        EthStaked -= amount;
        emit WithDividend(msg.sender, amount);
    }

    event WithPersonalEth(address buyer, uint256 amount);

    function withdrawPersonalEth(uint256 amount) public payable {
        require(
            _holderPersonalEth[msg.sender] >= amount,
            "amount is more than the personal balance"
        );
        _holderPersonalEth[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        EthStaked -= amount;
        emit WithPersonalEth(msg.sender, amount);
    }

    function balanceOf(address holder) public view returns (uint256) {
        return _holderBalances[holder];
    }

    function getTValues(uint256 tamount)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tfee = (tamount / 100) * commission;
        uint256 dist = (tamount / 100) * redistribution;
        uint256 drc = (tamount / 100) * direcREferCommission;
        uint256 Idrc = (tamount / 100) * inDirecREferCommission;
        uint256 afee = (tamount / 100) * adminFee;
        uint256 tTransfer = tamount - tfee;
        return (tTransfer, dist, drc, Idrc, afee);
    }

    function getSValues(uint256 tamount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 tfee = (tamount / 100) * SellingCommission;
        uint256 tTransfer = tamount - tfee;
        return (tTransfer, tfee);
    }

    uint256 Price = 5555;

    function ETHTOTOKEN(uint256 amount) public view returns (uint256) {
        uint256 tamount = (amount * Price);
        return tamount;
    }

    function SetPrice(uint256 price) public {
        require(msg.sender == _admin, "only admin can set price");
        Price = price;
    }

}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * Also in memory of JPK, miss you Dad.
     */
}
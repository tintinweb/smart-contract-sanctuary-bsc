pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";


contract INft {
    function isApprovedOrOwner(address spender, uint256 tokenId) public view returns (bool){}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {}

}

contract WorldCup {
    function isTokenId(uint256 tokenId) public view returns (uint256){}

    function ntfInitialAddress(uint256 tokenId) public view returns (address){}

    function attributeNumbersOf(uint256 _tokenId) public view returns(uint256,uint256,uint256){}

    function exchangeRateOf() public view returns (uint256) {}
    function discount() public view returns (uint256) {}
    function importSeedFromThird(uint256 number) public returns (uint256) {}

    function setFragmentNumbers(address _msgSender, uint256 number) public {}
    function setAttributeNumbers(uint256 _tokenId,uint256 _attributeNumber) public{}
    function setAttribute(uint256 _tokenId, uint256 _attributeNumber, uint256 _fusionNumber, uint256 _probability) public {}

}

contract PledgeSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256[76] _a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5,
    6, 7, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 1, 2, 3, 4, 1, 2, 3, 1, 2, 1, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 1, 2, 3, 4, 1, 2, 3, 1, 2, 1];
    uint256[51] _b = [5, 6, 7, 8, 9, 10, 5, 6, 7, 8, 9, 5, 6, 7, 8, 5, 6, 7, 5, 6, 5, 5, 6, 7, 8, 9,
    5, 6, 7, 8, 5, 6, 7, 5, 6, 5, 5, 6, 7, 8, 9, 5, 6, 7, 8, 5, 6, 7, 5, 6, 5];

    uint256 public pledgeAmount;
    uint256 public serviceCharge = 5;
    uint256 public serviceChargeProportion = 40;
    uint256 public purifyNFTAmount;

    bool public isPurifyNFTUSDT;
    bool public isPurifyNFTWSD;

    address public serviceChargeAddress;

    ERC20 public usdtContract;
    ERC20 public wsdContract;
    INft public NFTContract;
    WorldCup public worldCup;

    uint aa =1;

    mapping(uint256 => NFTOrder) public nftOrders;

    struct NFTOrder {
        bool isSell;
        uint256 sellAmount;
        address _to;
        uint256 sellTime;
        uint256 sellType;
    }

    mapping(address => PledgeOrder) public pledgeOrders;

    struct PledgeOrder {
        bool isPledge;
        uint256 pledgeAmount;
        uint256 multiple;
        uint256 pledgeTime;
        uint256 WithdrawalTime;
        uint256 incomeAmount;
    }

    event SellNFT(address indexed _msgSender, uint256 tokenId, uint256 amount, uint256 _type, uint256 _time);
    event CancelSellNFT(address indexed _msgSender, uint256 tokenId, uint256 _time);
    event BuyNFT(address indexed _msgSender, uint256 tokenId, uint256 amount, address indexed _serviceChargeAddress,
        uint256 _amount,address indexed _ntfInitialAddress,uint256 __amount,uint256 _time);
    event PledgeExchange(address indexed _msgSender, uint256 _amount, uint256 _time);
    event FragmentWithdrawal(address indexed _msgSender, uint256 amount, uint256 _time);
    event CancelFragment(address indexed _msgSender, uint256 amount, uint256 _time);
    event UpdatePurify(address indexed _msgSender, uint256 _tokenId, uint256 _attribute, uint256 _time);
    event Purify(address indexed _msgSender, uint256 _tokenId, uint256[] _attribute, uint256 _type, uint256 amount, uint256 _time);
    event FusionNFT(address indexed _msgSender, uint256 tokenId, uint256 _tokenId, bool _b, uint256 _time);


    constructor(address _USDTContract, address _wsdContract, address _NFTContract){
        usdtContract = ERC20(_USDTContract);
        wsdContract = ERC20(_wsdContract);
        NFTContract = INft(_NFTContract);
    }

    function sellNFT(uint256 tokenId, uint256 amount, uint256 _type) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(amount > 0, "The sale amount must be greater than 0");
        require(NFTContract.isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        require(NFTContract.isApprovedOrOwner(address(this), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(worldCup.isTokenId(tokenId) <= 0, "ERC721: transfer caller is not owner nor approved");
        NFTOrder storage order = nftOrders[tokenId];
        require(!order.isSell, "This NFT is already being sold!");
        order.isSell = true;
        order.sellAmount = amount;
        order.sellType = _type;
        order._to = msg.sender;
        order.sellTime = block.timestamp;

        emit SellNFT(msg.sender, tokenId, amount, _type, block.timestamp);

    }

    function cancelSellNFT(uint256 tokenId) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(NFTContract.isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        NFTOrder storage order = nftOrders[tokenId];
        require(order.isSell, "This NFT is already being sold!");
        order.isSell = false;
        order.sellAmount = 0;
        order.sellType = 0;
        order._to = address(0);
        order.sellTime = 0;
        emit CancelSellNFT(msg.sender, tokenId, block.timestamp);

    }

    function buyNFT(uint256 tokenId) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        NFTOrder storage order = nftOrders[tokenId];
        require(order.isSell, "This NFT is not for sale!");
        require(NFTContract.isApprovedOrOwner(order._to, tokenId), "ERC721: transfer caller is not owner nor approved");

        NFTContract.transferFrom(order._to, msg.sender, tokenId);

        uint256 amount = order.sellAmount.mul(serviceCharge).div(100);
        uint256 _amount = amount.mul(serviceChargeProportion).div(100);
        if (order.sellType == 1) {
            usdtContract.transferFrom(msg.sender, address(this), order.sellAmount);
            usdtContract.transfer(address(order._to), order.sellAmount.sub(amount));
            usdtContract.transfer(address(serviceChargeAddress), _amount);
            usdtContract.transfer(address(worldCup.ntfInitialAddress(tokenId)), amount.sub(_amount));

        } else {
            wsdContract.transferFrom(msg.sender, address(this), order.sellAmount);
            wsdContract.transfer(address(order._to), order.sellAmount.sub(amount));
            wsdContract.transfer(address(serviceChargeAddress), _amount);
            wsdContract.transfer(address(worldCup.ntfInitialAddress(tokenId)), amount.sub(_amount));
        }


        order.isSell = false;

        emit BuyNFT(msg.sender, tokenId, order.sellAmount,serviceChargeAddress,_amount,address(worldCup.ntfInitialAddress(tokenId)),amount.sub(_amount), block.timestamp);

    }


    function pledgeExchange(uint256 _multiple) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(pledgeAmount > 0, "base not set!");
        require(_multiple > 0, "Parameter must be greater than 0!");
        uint256 amount = pledgeAmount.mul(_multiple);
        wsdContract.transferFrom(msg.sender, address(this), amount);
        PledgeOrder storage pOrder = pledgeOrders[msg.sender];
        if (!pOrder.isPledge) {
            pOrder.pledgeAmount = amount;
            pOrder.isPledge = true;
            pOrder.multiple = _multiple;
            pOrder.pledgeTime = block.timestamp;
            pOrder.WithdrawalTime = block.timestamp;
            pOrder.incomeAmount = 0;

        } else {
            pOrder.incomeAmount = stakeEarningsFragmentOf(msg.sender);
            pOrder.pledgeAmount += amount;
            pOrder.multiple += _multiple;
            pOrder.WithdrawalTime = block.timestamp;

        }

        emit PledgeExchange(msg.sender, amount, block.timestamp);
    }

    function stakeEarningsFragmentOf(address _msgSender) public view returns (uint256){
        PledgeOrder storage pOrder = pledgeOrders[_msgSender];
        uint256 _times = 15 * 86400;
        uint256 diff = block.timestamp.sub(pOrder.WithdrawalTime);
        uint256 number = pOrder.multiple.mul(100000000).div(_times);
        uint256 nftNumber = 0;
        if (pOrder.isPledge) {
            if (diff > 0) {
                nftNumber = number.mul(diff).add(pOrder.incomeAmount);
            }
        }
        return nftNumber;

    }

    function fragmentWithdrawal() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        uint256 withdrawalNumber = stakeEarningsFragmentOf(msg.sender);
        uint256 number = withdrawalNumber.div(100000000);

        PledgeOrder storage pOrder = pledgeOrders[msg.sender];
        require(pOrder.isPledge, "No token pledge!");

        if (number > 0) {
            pOrder.WithdrawalTime = block.timestamp;
            pOrder.incomeAmount = withdrawalNumber.sub(number.mul(100000000));
            worldCup.setFragmentNumbers(msg.sender, number);
        }

        emit FragmentWithdrawal(msg.sender, number, block.timestamp);

    }

    function cancelFragment() public {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        PledgeOrder storage pOrder = pledgeOrders[msg.sender];
        require(pOrder.isPledge, "No token pledge!");
        fragmentWithdrawal();
        uint256 _pledgeAmount = pOrder.pledgeAmount;
        wsdContract.transfer(msg.sender, _pledgeAmount);
        pOrder.isPledge = false;
        pOrder.pledgeAmount = 0;
        pOrder.multiple = 0;

        emit CancelFragment(msg.sender, _pledgeAmount, block.timestamp);
    }

    function purifyNFTUSDT(uint256 tokenId, uint256 _number) public nonReentrant returns (uint256[] memory) {
        require(isPurifyNFTUSDT, "Staking is not enabled!");
        uint256 amount = _number.mul(purifyNFTAmount);
        usdtContract.transferFrom(msg.sender, address(this), amount);
        return _purifyNFT(tokenId, _number, uint256(1), amount);
    }

    function purifyNFTWSD(uint256 tokenId, uint256 _number) public nonReentrant returns (uint256[] memory) {
        require(isPurifyNFTWSD, "Staking is not enabled!");
        uint256 amount = purifyNFTAmount.mul(_number).mul(worldCup.exchangeRateOf()).div(10 ** wsdContract.decimals()).mul(worldCup.discount()).div(100);
        wsdContract.transferFrom(msg.sender, address(this), amount);
        return _purifyNFT(tokenId, _number, uint256(2), amount);
    }


    function _purifyNFT(uint256 tokenId, uint256 _number, uint256 _type, uint256 amount) private returns (uint256[] memory) {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(NFTContract.isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        require(worldCup.isTokenId(tokenId) <= 0, "NFT has been pledged!");
        uint256[] memory attributePurifyNumber = new uint256[](_number);

        (uint256 attributeNumbers,,) = worldCup.attributeNumbersOf(tokenId);
        for (uint256 i = 0; i < _number; i++) {
            if (attributeNumbers < 50000) {
                attributePurifyNumber[i] = _a[worldCup.importSeedFromThird(_a.length)].mul(10000);
            } else {
                attributePurifyNumber[i] = _b[worldCup.importSeedFromThird(_b.length)].mul(10000);
            }
            if (attributeNumbers < attributePurifyNumber[i]) {
                attributeNumbers = attributePurifyNumber[i];
            }

        }
        worldCup.setAttributeNumbers(tokenId,attributeNumbers);
        emit UpdatePurify(msg.sender, tokenId, attributeNumbers, block.timestamp);

        emit Purify(msg.sender, tokenId, attributePurifyNumber, _type, amount, block.timestamp);

        return attributePurifyNumber;
    }

    function fusionNFT(uint256 tokenId, uint256 _tokenId) public nonReentrant returns (bool){
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(worldCup.isTokenId(tokenId) <= 0, "NFT has been pledged!");
        require(worldCup.isTokenId(_tokenId) <= 0, "NFT has been pledged!");

        require(!isSellOf(tokenId), "This NFT is already being sold!");
        require(!isSellOf(_tokenId), "This NFT is already being sold!");
        (uint256 attributeNumber,uint256 fusionNumber,uint256 probability) = worldCup.attributeNumbersOf(tokenId);

        NFTContract.transferFrom(msg.sender, address(0), _tokenId);
        if (attributeNumber < 100000) {
            attributeNumber += 10000;
            fusionNumber = 9;
        } else {
            uint256 a = 1000;
            uint256 number = worldCup.importSeedFromThird(a.div(probability));
            require(fusionNumber < 30, "The maximum number of blends has been reached!");
            if (probability < 5) {
                (uint256 _attributeNumber,,) = worldCup.attributeNumbersOf(_tokenId);
                require(attributeNumber == _attributeNumber, "The two NFT attributes should be the same!");
                fusionNumber += 1;
                attributeNumber += attributeNumber.div(10);
            } else {
                if (number < 10) {
                    if (probability > 10) {
                        probability -= 10;
                    } else if (probability == 10) {
                        probability = 5;
                    } else if (probability > 1) {
                        probability -= 1;
                    }
                    fusionNumber += 1;
                    attributeNumber += attributeNumber.div(10);

                } else {
                    emit FusionNFT(msg.sender, tokenId, _tokenId, false, block.timestamp);
                    return false;
                }
            }

        }
        worldCup.setAttribute(tokenId,attributeNumber,fusionNumber, probability);
        emit FusionNFT(msg.sender, tokenId, _tokenId, true, block.timestamp);
        return true;
    }


    function setPledgeAmount(uint256 _amount) public onlyOwner {
        pledgeAmount = _amount * 10 ** wsdContract.decimals();
    }

    function setWorldCup(address _worldCup) public onlyOwner {
        worldCup = WorldCup(_worldCup);
    }

    function setServiceChargeAddress(address _serviceChargeAddress) public onlyOwner {
        serviceChargeAddress = _serviceChargeAddress;
    }

    function setServiceCharge(uint256 _serviceCharge) public onlyOwner {
        serviceCharge = _serviceCharge;
    }

    function setServiceChargeProportion(uint256 _serviceChargeProportion) public onlyOwner {
        serviceChargeProportion = _serviceChargeProportion;
    }

    function isSellOf(uint256 tokenId) public view returns (bool){
        return nftOrders[tokenId].isSell;
    }

    function setUpIsPurifyNFTWSD(bool _isPurifyNFTWSD) public onlyOwner {
        isPurifyNFTWSD = _isPurifyNFTWSD;
    }

    function setUpIsPurifyNFTUSDT(bool _isPurifyNFTUSDT) public onlyOwner {
        isPurifyNFTUSDT = _isPurifyNFTUSDT;
    }

    function setPurifyNFTAmount(uint256 _purifyNFTAmount) public onlyOwner {
        purifyNFTAmount = _purifyNFTAmount;
    }

}
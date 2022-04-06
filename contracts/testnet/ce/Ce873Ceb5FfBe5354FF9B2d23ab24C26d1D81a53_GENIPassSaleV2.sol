pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./utils/PermissionGroupUpgradeable.sol";
import "./utils/VerifySignature.sol";
import "./interfaces/IGENIPass.sol";
import "./interfaces/IExchangeRouter.sol";
import "./interfaces/IGENIPassSaleV2.sol";
import "./interfaces/IGENI.sol";
import "./interfaces/IGEMUNIBox.sol";

contract GENIPassSaleV2 is IGENIPassSaleV2, IERC721ReceiverUpgradeable, PermissionGroupUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    using SafeERC20 for IGENI;
    
    IGENIPass public geniPass;
    IGENI public geni;
    uint private constant SECONDS_PER_MONTH = 2629743; //2629743

    uint private referralBonusLv0;
    uint private referralBonusLv1;
    uint private referralBonusLv2;
    uint private referralBonusLv3;
    uint private referralBonusLv4;

    uint private startLv0;
    uint private startLv1;
    uint private startLv2;
    uint private startLv3;
    uint private startLv4;

    uint public discountRate;
    address public treasury;
    address public server;
    address public exchange;

    uint constant decimalRate = 10000;
    
    address public busd;
    
    mapping(uint => SaleInfo) public saleInfos;
    mapping(address => bool) private isEnterReferral;
    mapping(uint => bool) private isUsedNonce;
    mapping(address => mapping(uint => uint)) public passCount;

    uint private stonePoint;
    uint private topazPoint;
    uint private citrinePoint;
    uint private rubyPoint;
    uint private diamondPoint;

    IGEMUNIBox public mysteryBox;
    mapping(uint => BoxSaleInfo) public boxSaleInfos;
    mapping(address => mapping(uint => uint)) public boxPointCount;
    uint private boxPoint;

    modifier validRate(uint _rate) {
        require(_rate <= 1000000, "GENIPassSale: invalid rate");
        _;
    }

    function _initialize (
        IGENI geniAddr,
        IGENIPass geniPassAddr,
        address _treasury,
        address _server,
        address _exchange,
        address _busd,
        ReferalLevelParams memory params,
        ReferalBonus memory bonusParams   
    ) external initializer
    {
        __operatable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        require(params.startLv0 >= 0 && params.startLv1 > params.startLv0 && params.startLv2 > params.startLv1 && params.startLv3 > params.startLv2 && params.startLv4 > params.startLv3, "GENIPassSale: invalid level param");
        require(bonusParams.referralBonusLv0 <= 1000000 && bonusParams.referralBonusLv1 <= 1000000 && bonusParams.referralBonusLv2 <= 1000000 && bonusParams.referralBonusLv3 <= 1000000 && bonusParams.referralBonusLv4 <= 1000000, "GENIPassSale: invalid bonus param");
        geni = geniAddr;
        geniPass = geniPassAddr;
        server = _server;
        treasury = _treasury;
        exchange = _exchange;
        busd = _busd;
        startLv0 = params.startLv0;
        startLv1 = params.startLv1;
        startLv2 = params.startLv2;
        startLv3 = params.startLv3;
        startLv4 = params.startLv4;
        referralBonusLv0 = bonusParams.referralBonusLv0;
        referralBonusLv1 = bonusParams.referralBonusLv1;
        referralBonusLv2 = bonusParams.referralBonusLv2;
        referralBonusLv3 = bonusParams.referralBonusLv3;
        referralBonusLv4 = bonusParams.referralBonusLv4;
        discountRate = 100000;
    }

    function setGeniAddress(IGENI _geni) external onlyOwner {
        require(address(_geni) != address(0), "GENIPassSale: new address must be different address(0)");
        geni = _geni;
        emit SetGeni(address(_geni));
    }  
    
    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0));
        treasury = newTreasury;
        emit SetTreasury(newTreasury);
    }
    
    function setServer(address newServer) external onlyOwner {
        require(newServer != address(0));
        server = newServer;
        emit SetServer(newServer);
    }
    
    function setDiscountRate(uint value) external validRate(value) onlyOwner {
        discountRate = value;
        emit SetDiscountRate(value);
    }
    
    function setExchange(address _exchange) external onlyOwner {
        exchange = _exchange;
        emit SetExchange(_exchange);
    }

    function setReferralLevel(ReferalLevelParams memory params) external onlyOperator {
        require(params.startLv0 >= 0 && params.startLv1 > params.startLv0 && params.startLv2 > params.startLv1 && params.startLv3 > params.startLv2 && params.startLv4 > params.startLv3, "GENIPassSale: invalid param");
        startLv0 = params.startLv0;
        startLv1 = params.startLv1;
        startLv2 = params.startLv2;
        startLv3 = params.startLv3;
        startLv4 = params.startLv4;
        emit SetReferralLevel(startLv0, startLv1, startLv2, startLv3, startLv4);
    }

    function setReferalPoint(ReferalPointParams memory params) external onlyOperator {
        require(params.stonePoint >= 0 && params.topazPoint > params.stonePoint && params.citrinePoint > params.topazPoint && params.rubyPoint > params.citrinePoint && params.diamondPoint > params.rubyPoint, "GENIPassSale: invalid point");
        stonePoint = params.stonePoint;
        topazPoint = params.topazPoint;
        citrinePoint = params.citrinePoint;
        rubyPoint = params.rubyPoint;
        diamondPoint = params.diamondPoint;
        emit SetReferralPoint(stonePoint, topazPoint, citrinePoint, rubyPoint, diamondPoint);
    }

    function setReferalBoxPoint(uint point) external onlyOperator {
        require(point > 0, "GENIPassSale: invalid piont");
        boxPoint = point;
        emit SetReferralBoxPoint(point);
    }


    function setReferralBonusLevel0(uint _rate) external validRate(_rate) onlyOperator {
        referralBonusLv0 = _rate;
        emit SetReferralBonusLevel0(_rate);
    }

    function setReferralBonusLevel1(uint _rate) external validRate(_rate) onlyOperator {
        referralBonusLv1 = _rate;
        emit SetReferralBonusLevel1(_rate);
    }

    function setReferralBonusLevel2(uint _rate) external validRate(_rate) onlyOperator {
        referralBonusLv2 = _rate;
        emit SetReferralBonusLevel2(_rate);
    }

    function setReferralBonusLevel3(uint _rate) external validRate(_rate) onlyOperator {
        referralBonusLv3 = _rate;
        emit SetReferralBonusLevel3(_rate);
    }

    function setReferralBonusLevel4(uint _rate) external validRate(_rate) onlyOperator {
        referralBonusLv4 = _rate;
        emit SetReferralBonusLevel4(_rate);
    }

    function setMysteryBoxAddress(address _mysteryBox) external {
        require(_mysteryBox != address(0), "GENIPassSale: invalid address");
        mysteryBox = IGEMUNIBox( _mysteryBox);
        emit SetMysteryBoxAddress(_mysteryBox);
    }
    
    function putOnSale(address token, uint tokenId, uint price, uint startTime, uint expirationTime) public override whenNotPaused onlyOperator {
        require(token == address(geniPass) || token == address(mysteryBox), "GENIPassSale: invalid token");
        if (token == address(geniPass)) {
            require(startTime >= block.timestamp && expirationTime > startTime, "GENIPassSale: invalid time");
            geniPass.transferFrom(msg.sender, address(this), tokenId);
            
            SaleInfo storage saleInfo = saleInfos[tokenId];
            saleInfo.priceType = IGENIPass.PriceType.GENI;
            saleInfo.price = price;
            saleInfo.startTime = startTime;
            saleInfo.expirationTime = expirationTime;
        
            emit PassPutOnSale(tokenId, saleInfo.price, uint(IGENIPass.PriceType.GENI), treasury, startTime, expirationTime);
        } else {
            require(price > 0, "GENIPassSale: invalid price");
            require(startTime >= block.timestamp && expirationTime > startTime, "GENIPassSale: invalid time");
            mysteryBox.transferFrom(msg.sender, address(this), tokenId);
            
            BoxSaleInfo storage saleInfo = boxSaleInfos[tokenId];
            saleInfo.price = price;
            saleInfo.startTime = startTime;
            saleInfo.expirationTime = expirationTime;
        
            emit BoxPutOnSale(tokenId, saleInfo.price, treasury, startTime, expirationTime);
        }
    }

    
    function mintForSale(string memory serialNumber, uint price, IGENIPass.PassType passType, uint startTime, uint expirationTime) public override whenNotPaused onlyOperator {
        require(startTime >= block.timestamp, "GENIPassSale: invalid start time");
        require(expirationTime > startTime, "GENIPassSale: invalid end time");
        uint passId = geniPass.mint(address(this), serialNumber, passType);
        SaleInfo storage saleInfo = saleInfos[passId];
        saleInfo.priceType = IGENIPass.PriceType.GENI;
        saleInfo.price = price;
        saleInfo.startTime = startTime;
        saleInfo.expirationTime = expirationTime;
    
        emit PassPutOnSale(passId, saleInfo.price, uint(IGENIPass.PriceType.GENI), treasury, startTime, expirationTime);
    }

    function updateSale(address token, uint tokenId, uint price) external override onlyOperator whenNotPaused {
        require(token == address(geniPass) || token == address(mysteryBox), "GENIPassSale: invalid token");
        if(token == address(geniPass)) {
            SaleInfo storage saleInfo = saleInfos[tokenId];
            require(saleInfo.startTime > 0, "GENIPassSale: not for sale");
            require(block.timestamp <= saleInfo.expirationTime, "GENIPassSale: expired");
            require(price > 0, "GENIPassSale: invalid price");

            saleInfo.price = price;

            emit PassUpdateSale(tokenId, saleInfo.price, treasury);
        } else {
            BoxSaleInfo storage saleInfo = boxSaleInfos[tokenId];
            require(saleInfo.startTime > 0, "GENIPassSale: not for sale");
            require(block.timestamp <= saleInfo.expirationTime, "GENIPassSale: expired");
            require(price > 0, "GENIPassSale: invalid price");

            saleInfo.price = price;

            emit BoxUpdateSale(tokenId, saleInfo.price, treasury);
        }
    }

    
    function removeFromSale(address token, uint tokenId) external override onlyOperator whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(mysteryBox), "GENIPassSale: invalid token");
        if(token == address(geniPass)) {
            uint startTime = saleInfos[tokenId].startTime;
            require(startTime > 0, "GENIPassSale: not for sale");

            geniPass.transferFrom(address(this), msg.sender, tokenId);

            emit PassRemoveFromSale(tokenId, treasury);
            delete saleInfos[tokenId];
        } else {
            uint startTime = boxSaleInfos[tokenId].startTime;
            require(startTime > 0, "GENIPassSale: not for sale");

            mysteryBox.transferFrom(address(this), msg.sender, tokenId);

            emit BoxRemoveFromSale(tokenId, treasury);
            delete saleInfos[tokenId];
        }
    }


    function getCurrentPricePass(uint tokenId) public override view returns(uint pricePass) {
        bool isExistedToken = geniPass.exists(tokenId);
        require(isExistedToken, "GENIPassSale: invalid tokenId");
        SaleInfo memory saleInfo = saleInfos[tokenId];
        uint price = saleInfo.price;
        if (price != 0) {
            pricePass = getPrice(price);
        } else {
            pricePass = getDefauftPrice(tokenId);
        }
        
    }

    function getPrice(uint price) public view returns(uint priceGeni) {
        address[] memory pair = new address[](2);
        (pair[0], pair[1]) = (busd, address(geni));
        uint256[] memory amounts = IExchangeRouter(exchange).getAmountsOut(price, pair);
        priceGeni = amounts[1];
    }


    function getDefauftPrice (uint passId) internal view returns (uint pricePass) {
        IGENIPass.PassType passType = geniPass.getPass(passId).passType; 
        if (passType == IGENIPass.PassType.Stone) {
            pricePass = 375;
        } else if (passType == IGENIPass.PassType.Topaz) {
            pricePass = 850;
        } else if (passType == IGENIPass.PassType.Citrine) {
            pricePass = 1450;
        } else if (passType == IGENIPass.PassType.Ruby) {
            pricePass = 2100;
        } else if (passType == IGENIPass.PassType.Diamond) {
            pricePass = 3100;
        }
        pricePass = pricePass * 10 ** uint256(IERC20Metadata(address(geni)).decimals());

    }

    function getPricePass(uint passId, uint price, IGENIPass.PriceType priceType) public view override returns(uint pricePass) {
        bool isExistedToken = geniPass.exists(passId);
        require(isExistedToken, "GENIPassSale: invalid tokenId");
        IGENIPass.PassType passType = geniPass.getPass(passId).passType;  
        if (price != 0) {
            pricePass = price;
        } else {
            if (priceType == IGENIPass.PriceType.BNB) {
                revert("GENIPassSale: not support");
            } else {
                if (passType == IGENIPass.PassType.Stone) {
                    pricePass = 375;
                } else if (passType == IGENIPass.PassType.Topaz) {
                    pricePass = 850;
                } else if (passType == IGENIPass.PassType.Citrine) {
                    pricePass = 1450;
                } else if (passType == IGENIPass.PassType.Ruby) {
                    pricePass = 2100;
                } else if (passType == IGENIPass.PassType.Diamond) {
                    pricePass = 3100;
                }
                pricePass = pricePass * 10 ** uint256(IERC20Metadata(address(geni)).decimals());
            }
        }
    }

    function putOnSaleBatch(CreateSaleToken[] memory input) external override whenNotPaused onlyOperator {
        for (uint i = 0; i < input.length; i++) {
            putOnSale(input[i].token,input[i].tokenId, input[i].price, input[i].startTime, input[i].expirationTime);
        }
    }
    
    function mintForSaleBatch(CreateSalePasses[] memory input) external override whenNotPaused onlyOperator {
        for (uint i = 0; i < input.length; i++) {
            mintForSale(input[i].serialNumber, input[i].price, input[i].passType, input[i].startTime, input[i].expirationTime);
        }
    }
    
    function purchase(address token, uint tokenId, uint buyPrice) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(mysteryBox), "GENIPassSale: invalid token");
        if (token == address(geniPass)) {
            SaleInfo storage saleInfo = saleInfos[tokenId];
        
            address buyer = msg.sender;
            require(saleInfo.startTime > 0, "GENIPassSale: not for sale");
            require(block.timestamp >= saleInfo.startTime, "GENIPassSale: Sale has not started");
            require(block.timestamp <= saleInfo.expirationTime, "GENIPassSale: expired to purchase");
            require(buyer != treasury, "GENIPassSale: treasury can not buy");

            uint busdPrice = saleInfo.price;
            require(buyPrice == busdPrice, "GENIPassSale: invalid trade price");

            uint salePrice = getCurrentPricePass(tokenId);
            uint payPrice = calculatePayPrice(buyer, salePrice);

            geni.safeTransferFrom(buyer, treasury, payPrice);
            
            geniPass.transferFrom(address(this), buyer, tokenId);
            saleInfo.startTime = 0;
            saleInfo.expirationTime = 0;
            emit PassBought(tokenId, buyer, treasury, saleInfo.price, payPrice);
        } else {
            BoxSaleInfo storage saleInfo = boxSaleInfos[tokenId];
        
            address buyer = msg.sender;
            require(saleInfo.startTime > 0, "GENIPassSale: not for sale");
            require(block.timestamp >= saleInfo.startTime, "GENIPassSale: Sale has not started");
            require(block.timestamp <= saleInfo.expirationTime, "GENIPassSale: expired to purchase");
            require(buyer != treasury, "GENIPassSale: treasury can not buy");

            uint busdPrice = saleInfo.price;
            require(buyPrice == busdPrice, "GENIPassSale: invalid trade price");

            uint salePrice = getPrice(busdPrice);
            uint payPrice = calculatePayPrice(buyer, salePrice);

            geni.safeTransferFrom(buyer, treasury, payPrice);
            
            mysteryBox.transferFrom(address(this), buyer, tokenId);
            saleInfo.startTime = 0;
            saleInfo.expirationTime = 0;
            emit BoxBought(tokenId, buyer, treasury, saleInfo.price, payPrice);
        }
    }


    function getMessageHash(
        address _to,
        uint256 _nonce
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _nonce));
    }
    
    function purchaseWithReferral(address token, uint tokenId, uint buyPrice, address referralAddress, uint nonce, bytes memory signature) external override whenNotPaused nonReentrant {
        require(token == address(geniPass) || token == address(mysteryBox), "GENIPassSale: invalid token");
        if(token == address(geniPass)) {
            SaleInfo storage saleInfo = saleInfos[tokenId];
            uint startTime = saleInfo.startTime;
            
            address buyer = msg.sender;
            require(startTime > 0, "GENIPassSale: not for sale");
            require(block.timestamp >= startTime, "GENIPassSale: Sale has not started");
            require(block.timestamp <= saleInfo.expirationTime, "GENIPassSale: expired to purchase");
            require(buyer != treasury, "GENIPassSale: owner can not buy");
            require(buyPrice == saleInfo.price, "GENIPassSale: invalid trade price");
            uint salePrice = getCurrentPricePass(tokenId);
            uint payPrice = calculatePayPrice(buyer, salePrice);
            
            checkRecoverAddress(referralAddress, nonce, signature, buyer);
            
            uint monthIndex = getMonthIndex(startTime);

            uint passAmount = passCount[referralAddress][monthIndex] + getReferalPoint(tokenId);
            
            salePrice = payPrice * (1000000 -  getDiscountReferral(passAmount)) / decimalRate / 100;
            geni.safeTransferFrom(buyer, treasury, salePrice);
            if (getDiscountReferral(passAmount) > 0) {
                geni.safeTransferFrom(buyer, referralAddress, payPrice - salePrice);
            }

            geniPass.transferFrom(address(this), buyer, tokenId);

            passCount[referralAddress][monthIndex] = passAmount;

            saleInfo.startTime = 0;
            saleInfo.expirationTime = 0;
            emit PassBoughtWithReferral(tokenId, buyer, treasury, referralAddress, nonce, saleInfo.price, payPrice, payPrice - salePrice);
        } else {
            BoxSaleInfo storage saleInfo = boxSaleInfos[tokenId];
            uint startTime = saleInfo.startTime;
            
            address buyer = msg.sender;
            require(startTime > 0, "GENIPassSale: not for sale");
            require(block.timestamp >= startTime, "GENIPassSale: Sale has not started");
            require(block.timestamp <= saleInfo.expirationTime, "GENIPassSale: expired to purchase");
            require(buyer != treasury, "GENIPassSale: owner can not buy");
            require(buyPrice == saleInfo.price, "GENIPassSale: invalid trade price");
            uint salePrice = getPrice(saleInfo.price);
            uint payPrice = calculatePayPrice(buyer, salePrice);
            
            checkRecoverAddress(referralAddress, nonce, signature, buyer);
            
            uint monthIndex = getMonthIndex(startTime);

            uint boxPointAmount = boxPointCount[referralAddress][monthIndex] + getReferalPoint(tokenId);
            
            salePrice = payPrice * (1000000 -  getDiscountReferral(boxPointAmount)) / decimalRate / 100;
            geni.safeTransferFrom(buyer, treasury, salePrice);
            if (getDiscountReferral(boxPointAmount) > 0) {
                geni.safeTransferFrom(buyer, referralAddress, payPrice - salePrice);
            }

            mysteryBox.transferFrom(address(this), buyer, tokenId);

            boxPointCount[referralAddress][monthIndex] = boxPointAmount;

            saleInfo.startTime = 0;
            saleInfo.expirationTime = 0;
            emit BoxBoughtWithReferral(tokenId, buyer, treasury, referralAddress, nonce, saleInfo.price, payPrice, payPrice - salePrice);
        }

    }


    function checkRecoverAddress(address referral, uint nonce, bytes memory signature, address buyer) internal view {
        address recoverAddress = VerifySignature.recoverSigner(VerifySignature.getEthSignedMessageHash(getMessageHash( referral, nonce)), signature);
        
        require(recoverAddress == server, "GENIPassSale: invalid signature");
        require(referral != buyer, "GENIPassSale: invalid buyer");
    }
    
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function pause() external onlyOperator {
        _pause();
    }

    function unpause() external onlyOperator {
        _unpause();
    }

    function withdrawNftEmergency(TokenInfoWthdraw[] memory inputs) external onlyOperator {
        for (uint i = 0; i < inputs.length; i++) {
            address token = inputs[i].token;
            uint tokenId = inputs[i].tokenId;
            address recipient = inputs[i].recipient;
            require(IERC721(token).ownerOf(tokenId) == address(this), "GENIPassSale: not for sale");

            IERC721(token).transferFrom(address(this), recipient, tokenId);
            emit WithdrawNftToken(token, tokenId, recipient);

            delete saleInfos[tokenId];
        }
    }

    function withdrawTokenEmergency(address token, uint amount, address recipient) external whenPaused onlyOperator {
        require(amount > 0, "GENIPassSale: invalid price");
        require(IERC20(token).balanceOf(address(this)) >= amount, "GENIPassSale: not enough balance");

        IERC20(token).transferFrom(address(this), recipient, amount);

        emit WithdrawToken(token, recipient, amount);
    }


    function getMonthIndex(uint startTime) public view returns (uint monthIndex){
        uint index = (block.timestamp - startTime) / SECONDS_PER_MONTH;
        monthIndex = index + 1;
    }

    function getDiscountReferral(uint amount) internal view returns (uint referralBonus){
        if (amount >= startLv0 && amount < startLv1)
            referralBonus = referralBonusLv0;
        else if (amount >= startLv1 && amount < startLv2)
            referralBonus = referralBonusLv1;
        else if (amount >= startLv2 && amount < startLv3)
            referralBonus = referralBonusLv2;
        else if (amount >= startLv3 && amount < startLv4)
            referralBonus = referralBonusLv3;
        else if (amount >= startLv4)
            referralBonus = referralBonusLv4;
    }

    function getReferalPoint (uint passId) internal view returns (uint poins) {
        IGENIPass.PassType passType = IGENIPass(address(geniPass)).getPass(passId).passType;
        if (passType == IGENIPass.PassType.Stone) {
            poins = stonePoint;
        } else if (passType == IGENIPass.PassType.Topaz) {
            poins = topazPoint;
        } else if (passType == IGENIPass.PassType.Citrine) {
            poins = citrinePoint;
        } else if (passType == IGENIPass.PassType.Ruby) {
            poins = rubyPoint;
        } else if (passType == IGENIPass.PassType.Diamond) {
            poins = diamondPoint;
        }
    }

    function getReferalPoint() public view returns (uint stone, uint topaz, uint citrine, uint ruby, uint diamond, uint box) {
        return (stonePoint, topazPoint, citrinePoint, rubyPoint, diamondPoint, boxPoint);
    }

    function getStartLevel() public view returns (uint lv0, uint lv1, uint lv2, uint lv3, uint lv4) {
        return (startLv0, startLv1, startLv2, startLv3, startLv4);
    }

    function getReferalBonus() public view returns (uint bonusLv0, uint bonusLv1, uint bonusLv2, uint bonusLv3, uint bonusLv4) {
        return (referralBonusLv0, referralBonusLv1, referralBonusLv2, referralBonusLv3, referralBonusLv4);
    }

    function calculatePayPrice(address buyer, uint salePrice) internal view returns (uint payPrice) {
        payPrice = geniPass.balanceOf(buyer) > 0 ? (salePrice - (salePrice * discountRate / 100 / decimalRate)) : salePrice;
    }

}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library VerifySignature {

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract PermissionGroupUpgradeable is OwnableUpgradeable {

    mapping(address => bool) public operators;
    event AddOperator(address newOperator);
    event RemoveOperator(address operator);

    function __operatable_init() internal initializer {
        __Ownable_init();
        operators[owner()] = true;
    }

    modifier onlyOperator {
        require(operators[msg.sender], "Operatable: caller is not the operator");
        _;
    }

    function addOperator(address operator) external onlyOwner {
        operators[operator] = true;
        emit AddOperator(operator);
    }

    function removeOperator(address operator) external onlyOwner {
        operators[operator] = false;
        emit RemoveOperator(operator);
    }
}

pragma solidity ^0.8.0;
import "./IGENIPass.sol";

interface IGENIPassSaleV2 {
    struct SaleInfo {
        uint price;
        IGENIPass.PriceType priceType;
        uint startTime;
        uint expirationTime;
    }
    
    struct CreateSalePasses{
        string serialNumber;
        uint price;
        IGENIPass.PassType passType;
        uint startTime;
        uint expirationTime;
    }

    struct CreateSaleToken{
        address token;
        uint tokenId;
        uint price;
        uint startTime;
        uint expirationTime;
    }

    struct ReferalBonus {
        uint referralBonusLv0;
        uint referralBonusLv1;
        uint referralBonusLv2;
        uint referralBonusLv3;
        uint referralBonusLv4;
    }

    struct ReferalLevelParams {
        uint startLv0;
        uint startLv1;
        uint startLv2;
        uint startLv3;
        uint startLv4;
    }

    struct ReferalPointParams {
        uint stonePoint;
        uint topazPoint;
        uint citrinePoint;
        uint rubyPoint;
        uint diamondPoint;
    }

    struct BoxSaleInfo {
        uint price;
        uint startTime;
        uint expirationTime;
    }
    struct TokenInfoWthdraw {
        address token;
        uint tokenId; 
        address recipient;
    }

    event SetServer(address newServer);
    event SetTreasury(address newTreasury);
    event SetGeni(address newGeni);
    event SetDiscountRate(uint value);
    event SetExchange(address _exchange);
    event SetReferralLevel(uint startLv0, uint startLv1, uint startLv2, uint startLv3, uint startLv4);
    event SetReferralPoint(uint stonePoint, uint topazPoint, uint citrinePoint, uint rubyPoint, uint diamondPoint);
    event SetReferralBonusLevel0(uint _rate);
    event SetReferralBonusLevel1(uint _rate);
    event SetReferralBonusLevel2(uint _rate);
    event SetReferralBonusLevel3(uint _rate);
    event SetReferralBonusLevel4(uint _rate);
    event SetMysteryBoxAddress(address _mysteryBox);
    event SetReferralBoxPoint(uint point);

    event PassPutOnSale(uint indexed passId, uint price, uint priceType, address seller, uint startTime, uint expirationTime);
    event PassUpdateSale(uint indexed passId, uint newPrice, address seller);
    event PassRemoveFromSale(uint indexed passId, address seller);
    event PassBought(uint indexed passId, address buyer, address seller, uint256 price, uint discountedPrice);
    event PassBoughtWithReferral(uint indexed passId, address buyer, address seller, address referal, uint nonce, uint256 price, uint discountedPrice, uint referalBonus);
    event WithdrawGeniPass(address seller, address to, uint indexed tokenId);
    event WithdrawNftToken(address token, uint indexed tokenId, address to);
    event WithdrawToken(address token, address to, uint amount);

    event BoxPutOnSale(uint indexed tokenId, uint price, address seller, uint startTime, uint expirationTime);
    event BoxUpdateSale(uint indexed tokenId, uint newPrice, address seller);
    event BoxRemoveFromSale(uint indexed tokenId, address seller);
    event BoxBought(uint indexed tokenId, address buyer, address seller, uint256 price, uint discountedPrice);
    event BoxBoughtWithReferral(uint indexed tokenId, address buyer, address seller, address referal, uint nonce, uint256 price, uint discountedPrice, uint referalBonus);
    event BoxWithdrawToken(address token, address to, uint amount);
    
    function putOnSale(address token, uint tokenId, uint price, uint startTime, uint expirationTime) external;
    function mintForSale(string memory serialNumber, uint price, IGENIPass.PassType passType, uint startTime, uint expirationTime) external;
    function updateSale(address token, uint tokenId, uint price) external;
    function removeFromSale(address token, uint tokenId) external;
    function putOnSaleBatch(CreateSaleToken[] memory input) external;
    function mintForSaleBatch(CreateSalePasses[] memory input) external;
    function purchase(address token, uint tokenId, uint buyPrice) external;
    function purchaseWithReferral(address token, uint tokenId, uint buyPrice, address referalAddress, uint nonce, bytes memory signature) external;
    function getPricePass(uint tokenId, uint price, IGENIPass.PriceType priceType) external view returns(uint);
    function getCurrentPricePass(uint tokenId) external view returns(uint);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IGENIPass is IERC721Upgradeable {
    enum PassType { Stone, Topaz, Citrine, Ruby, Diamond }
    enum PriceType { BNB, GENI }

    struct GeniPass {
        string serialNumber;
        PassType passType;
        bool isActive;
    }
    
    event SetActive(uint indexed passId, bool isActive);
    event PassCreated(address indexed owner, uint indexed passId, uint passType, string serialNumber);
    event LockPass(uint indexed passId);
    event UnLockPass(uint indexed passId);
    
    function burn(uint tokenId) external;
    
    function mint(address to, string memory serialNumber, PassType passType) external returns(uint tokenId);
    
    function getPass(uint passId) external view returns (GeniPass memory pass);

    function exists(uint passId) external view returns (bool);

    function setActive(uint tokenId, bool _isActive) external;

    function lockPass(uint passId) external;

    function unLockPass(uint passId) external;

    function permit(address owner, address spender, uint tokenId, bytes memory _signature) external;
    
    function isLocked(uint tokenId) external returns(bool);
}

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGENI is IERC20 {
    function mint(address to, uint256 amount) external;
    
    function burn(uint amount) external;

    event SetLpToken(address lpToken);
    event SetBusd(address _busd);
    event SetExchange(address lpToken);
    event SetAntiWhaleAmountBuy(uint256 amount);
    event SetAntiWhaleAmountSell(uint256 amount);
    event SetAntiWhaleTimeSell(uint256 timeSell);
    event SetAntiWhaleTimeBuy(uint256 timeBuy);
    event AddListWhales(address[] _whales);
    event RemoveFromWhales(address[] _whales);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IGEMUNIBox is IERC721Upgradeable {

    /**
     * @notice mint Item
     */
    function mintBox(address _to) external returns(uint tokenId);
    function burnBox(uint256 _tokenId) external;
    
    function exists(uint passId) external view returns (bool);

    event BoxCreated(uint indexed tokenId, address indexed owner);
    event BoxRemoved(uint indexed tokenId);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IExchangeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}
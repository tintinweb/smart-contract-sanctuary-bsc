pragma solidity ^0.8.0;
import "./interfaces/IGENIPass.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/PermissionGroupUpgradeable.sol";
import "./interfaces/IExchangeRouter.sol";
import "./interfaces/IGEMUNIItem.sol";
import "./interfaces/IGEMUNILeasing.sol";

contract GEMUNILeasing is PermissionGroupUpgradeable, IGEMUNILeasing{
    address public geniPass;
    address public gemuniItem;
    IERC20 public geni;

    address public treasury;
    uint public minPasses;
    uint private constant weekPerSecond = 604800;
    
    address public busd;
    address public exchange;

    mapping(address => mapping(uint => LeasingInfo)) public leasingInfo;
    mapping(address => mapping(uint => LeasingGuildInfo)) public leasingGuildInfo;
    mapping(address => mapping(uint => RenterInfo)) public renterInfo;
    mapping(address => bool) public gameGuild;

    function _initialize (
        IERC20 geniAddr,
        address geniPassAddr,
        address gemuniItemAddr,
        address _treasury,
        address _busd,
        address _exchange
    ) external initializer {
        __operatable_init();
        geni = geniAddr;
        geniPass = geniPassAddr;
        gemuniItem = gemuniItemAddr;
        treasury = _treasury;
        busd = _busd;
        exchange = _exchange;
    }

    function setInput(address _gemuniItem, address _geniPass, address _treasury, address _exchange) internal {
        require(_gemuniItem != address(0) && _treasury != address(0) && _geniPass != address(0) && _exchange != address(0), "Lending: invalid address");
        gemuniItem = _gemuniItem;
        treasury = _treasury;
        geniPass = _geniPass;
        exchange = _exchange;
        emit SetInput(_gemuniItem, _geniPass, _treasury, _exchange);
    }

    function convertPrice(uint busdPrice) internal view returns(uint geniPrice) {
        address[] memory pair = new address[](2);
        (pair[0], pair[1]) = (busd, address(geni));
        uint256[] memory amounts = IExchangeRouter(exchange).getAmountsOut(busdPrice, pair);
        geniPrice = amounts[1];
    }

    function putOnLeasing(address nftToken, uint[] memory tokenIds, uint minDuration, uint maxDuration, uint[] memory pricePerWeeks, bool transferWallet,uint mortgageAmount) public override {
        require(nftToken != address(0), "Leasing: invalid address");
        require(minDuration > 0 && maxDuration > minDuration, "Leasing: invalid input");
        require(pricePerWeeks.length == tokenIds.length, "Leasing: invalid price length");
        if (operators[msg.sender]) {
            for (uint i = 0; i < tokenIds.length; i++) {
                require(pricePerWeeks[i] > 0, "Leasing: invalid price");
                LeasingInfo storage leasing = leasingInfo[nftToken][tokenIds[i]];
                leasing.lender = treasury;
                leasing.price = pricePerWeeks[i];
                leasing.minDuration = minDuration * weekPerSecond;
                leasing.maxDuration = maxDuration * weekPerSecond;
                leasing.isTransferWallet = transferWallet;
                leasing.mortgageAmount = mortgageAmount;
                IERC721(nftToken).transferFrom(msg.sender, address(this), tokenIds[i]);
            }
        } else if (gameGuild[msg.sender]) {
            for (uint i = 0; i < tokenIds.length; i++) {
                require(pricePerWeeks[i] > 0, "Leasing: invalid price");
                LeasingGuildInfo storage leasingGuild = leasingGuildInfo[nftToken][tokenIds[i]];
                leasingGuild.gameGuild = msg.sender;
                leasingGuild.price = pricePerWeeks[i];
                leasingGuild.minDuration = minDuration * weekPerSecond;
                leasingGuild.maxDuration = maxDuration * weekPerSecond;
                leasingGuild.isTransferWallet = transferWallet;
                leasingGuild.mortgageAmount = mortgageAmount;
                IERC721(nftToken).transferFrom(msg.sender, address(this), tokenIds[i]);
            }
        } else {
            revert("Leasing: invalid sender");
        }

        emit PutOnLeasing(nftToken, tokenIds, minDuration, maxDuration, pricePerWeeks, msg.sender, mortgageAmount);
    }

    function registerLeasing(address nftToken, uint[] memory tokenIds, uint duration, uint minDuration, uint maxDuration, uint[] memory pricePerWeek, uint mortgageAmount, uint rentalPrice) external override {
        require(gameGuild[msg.sender], "Lending: not game guild");
        require(tokenIds.length >= minPasses, "Leasing: invalid number of passes");
        uint totalRental;
        if (nftToken != geniPass && nftToken != gemuniItem) {
            require(mortgageAmount > 0, "Leasing: invalid deposit amount");
        } else {
            require(mortgageAmount == 0, "Leasing: invalid deposit amount");
        }
        for(uint i = 0; i < tokenIds.length; i++) {
            LeasingInfo storage leasing = leasingInfo[nftToken][tokenIds[i]];
            LeasingGuildInfo storage leasingGuild = leasingGuildInfo[nftToken][tokenIds[i]];
            RenterInfo memory rent = renterInfo[nftToken][tokenIds[i]];
            uint min = leasing.minDuration;
            uint max = leasing.maxDuration;
            totalRental  += leasing.price;
            require(leasing.lender != address(0), "Leasing: not put on leasing");
            require(leasingGuild.gameGuild == address(0) && rent.renter == address (0),"Leasing: already registered or rented");
            require(duration >= min && duration <= max, "Leasing: invalid duration");

            // require(minDuration > 0 && minDuration < min  && maxDuration > minDuration && maxDuration < max && pricePerWeek > leasing.price, "Leasing: invalid input");

            leasingGuild.gameGuild = msg.sender;
            leasingGuild.duration = duration * weekPerSecond;

            leasingGuild.price = pricePerWeek[i];
            leasingGuild.minDuration = minDuration * weekPerSecond;
            leasingGuild.maxDuration = maxDuration * weekPerSecond;
            leasingGuild.isTransferWallet = leasing.isTransferWallet;
            leasingGuild.mortgageAmount = mortgageAmount;
        }
        totalRental *= duration;
        uint totalGeniAmount = convertPrice(totalRental);
        require(rentalPrice == totalRental, "Leasing: invalid price");
        geni.transferFrom(msg.sender, treasury, totalGeniAmount);
        emit RegisterLeasing(nftToken, tokenIds, duration, minDuration, maxDuration, pricePerWeek, mortgageAmount, rentalPrice);
    }

    function updateLeasing(address nftToken, uint tokenId, uint newMinDuration, uint newMaxDuration, uint newPricePerSecond, bool newTransferWallet) external override {
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        RenterInfo memory renter = renterInfo[nftToken][tokenId];
        if (msg.sender == guild.gameGuild) {
            require(IERC721(nftToken).ownerOf(tokenId) == address(this) && renter.renter == address(0), "Lending: already rented");
            require(newMinDuration > 0 && newMaxDuration > newMinDuration && newMaxDuration < leasing.maxDuration && newPricePerSecond > leasing.price, "Leasing: invalid input");
            guild.minDuration = newMinDuration;
            guild.maxDuration = newMaxDuration;
            guild.price = newPricePerSecond;
            if (leasing.lender == address(0)) {
                guild.isTransferWallet = newTransferWallet;
            } else {
                guild.isTransferWallet = leasing.isTransferWallet;
            }
        } else if (operators[msg.sender]) {
            require(leasing.price > 0, "Lending: not on lending");
            require(IERC721(nftToken).ownerOf(tokenId) == address(this) && guild.gameGuild == address(0) && renter.renter == address(0), "Lending: already rented");
            leasing.minDuration = newMinDuration;
            leasing.maxDuration = newMaxDuration;
            leasing.price = newPricePerSecond;
            leasing.isTransferWallet = newTransferWallet;
        } else {
            revert("Leasing: invalid sender");
        }
        emit UpdateLeasing(nftToken, tokenId, newMinDuration, newMaxDuration, newPricePerSecond, newTransferWallet);
    }
    
    function cancelLeasing(address nftToken, uint tokenId) external override {
        LeasingInfo memory leasing = leasingInfo[nftToken][tokenId];
        LeasingGuildInfo memory guild = leasingGuildInfo[nftToken][tokenId];
        RenterInfo memory renter = renterInfo[nftToken][tokenId];
        if (msg.sender == guild.gameGuild) {
            require(leasing.lender == address(0), "Leasing: invalid sender");
            require(IERC721(nftToken).ownerOf(tokenId) == address(this) && renter.renter == address(0), "Lending: already rented");
            IERC721(nftToken).transferFrom(address(this), guild.gameGuild, tokenId);
            delete leasingGuildInfo[nftToken][tokenId];
        } else if (operators[msg.sender]) {
            require(leasing.price > 0, "Lending: not on lending");
            require(IERC721(nftToken).ownerOf(tokenId) == address(this) && guild.gameGuild == address(0) && renter.renter == address(0), "Lending: already rented");
            IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
            delete leasingInfo[nftToken][tokenId];
        } else {
            revert("Leasing: invalid sender");
        }
 
        emit CancelLeasing(nftToken, tokenId);
    }

    function setNumberPassesOfGameGuild(uint _minPasses) external onlyOperator {
        require (_minPasses > 0, "invalid min max");
        minPasses = _minPasses;
    }

    function addListGameGuild(address[] memory users) external override onlyOperator {
        require(users.length > 0, "Leasing: list user is empty");
        for (uint i = 0; i < users.length; i++) {
            require(!gameGuild[users[i]]);
            require(users[i] != address(0), "Leasing: invalid address");
            gameGuild[users[i]] = true;
        }
        emit AddListGameGuild(users);
    }

    function removeFromGuilds(address[] calldata users) external override onlyOperator {
        require(users.length > 0, "Leasing: list user is empty");
        for (uint i; i < users.length; i++) {
            require(gameGuild[users[i]]);
            gameGuild[users[i]] = false;
        }
        emit RemoveFromGuild(users);
    }

    function rentPass(address nftToken, uint tokenId, uint duration, uint price, bytes memory sig) external override {
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        RenterInfo storage renter = renterInfo[nftToken][tokenId];

        require(renter.renter == address(0), "Leasing: already rented");
        require(leasing.lender != address(0) || guild.gameGuild != address(0), "Leasing: not on leasing");

        duration = duration * weekPerSecond;
        uint rentalPriceGeni;
        if (guild.gameGuild != address(0)) {
            rentalPriceGeni = rentPassFromGameGuild(guild, duration, price);
        } else if (leasing.lender != address(0) && guild.gameGuild == address(0)) {
            rentalPriceGeni = rentPassFromAdmin(leasing, duration, price);
        } 

        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);

        if (nftToken == geniPass) {
            
            IGENIPass(geniPass).permit(msg.sender, address(this), tokenId, sig);

            IGENIPass(geniPass).setActive(tokenId, true);

            if(!IGENIPass(geniPass).isLocked(tokenId)) {

                IGENIPass(geniPass).lockPass(tokenId);
            }
        } else if (nftToken == gemuniItem) {
            IGEMUNIItem(gemuniItem).permit(msg.sender, address(this), tokenId, sig);

            if(!IGEMUNIItem(gemuniItem).isLocked(tokenId)) {

                IGEMUNIItem(gemuniItem).unLockItem(tokenId);
            }
        } else {
            geni.transferFrom(msg.sender, address(this), leasing.mortgageAmount);
        }
        renter.renter = msg.sender;
        renter.startLending = block.timestamp;
        renter.duration = duration;
        emit RentPass(nftToken, tokenId, rentalPriceGeni, renter.startLending, duration);
    }

    function rentPassFromGameGuild(LeasingGuildInfo storage guild, uint duration, uint price) internal returns(uint rentalPriceGeni) {
        require(guild.price > 0, "Leasing: not on game guild");
        require(duration >= guild.minDuration && duration <= guild.maxDuration, "Leasing: invalid duration");
        uint rentalPrice = guild.price * duration;
        require(price == rentalPrice, "Lending: invalid price");
        rentalPriceGeni = convertPrice(rentalPrice);
        
        geni.transferFrom(msg.sender, guild.gameGuild, rentalPriceGeni);
    }

    function rentPassFromAdmin(LeasingInfo storage leasing, uint duration, uint price) internal returns(uint rentalPriceGeni) {
        require(leasing.price > 0, "Leasing: not on leasing");
        require(duration >= leasing.minDuration && duration <= leasing.maxDuration, "Leasing: invalid duration");
        uint rentalPrice = leasing.price * duration;
        require(price == rentalPrice, "Lending: invalid price");
        rentalPriceGeni = convertPrice(rentalPrice);

        geni.transferFrom(msg.sender, leasing.lender, rentalPriceGeni);
    }


    function rentMore(address nftToken, uint tokenId, uint amount) external override {
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        RenterInfo storage renter = renterInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        require(amount > 0,"GEMUNILending: invalid amount");
        uint caculatedDuration;
        uint geniPrice;
        if (msg.sender == renter.renter && guild.gameGuild != address(0)) {
            uint endLending = guild.startLending + guild.duration;
            require(block.timestamp <= endLending, "Leasing: over time");
            geniPrice = convertPrice(guild.price);
            caculatedDuration =  amount / geniPrice;
            renter.duration += caculatedDuration;
            geni.transferFrom(msg.sender, guild.gameGuild, geniPrice);
            
        } else if (msg.sender == guild.gameGuild || msg.sender == renter.renter) {
            geniPrice = convertPrice(leasing.price);
            caculatedDuration =  amount / geniPrice;
            if (msg.sender == guild.gameGuild) {
                guild.duration += caculatedDuration;
            } else {
                renter.duration += caculatedDuration;
            }
            geni.transferFrom(msg.sender, leasing.lender, geniPrice);
        } else {
            revert ("Leasing: invalid sender");
        }

        emit RentMore(nftToken, tokenId, geniPrice, caculatedDuration);
    }

    function finishRenting(address nftToken, uint tokenId) external override {
        RenterInfo storage renter = renterInfo[nftToken][tokenId];
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        require(msg.sender == guild.gameGuild || msg.sender == renter.renter, "Leasing: invalid lender");
        if (msg.sender == guild.gameGuild) {
            require(renter.renter == address(0), "Leasing: need to retrieve pass form user");
            if (nftToken != geniPass || nftToken != gemuniItem) {
                geni.transfer(msg.sender, leasing.mortgageAmount);
            }
            delete leasingGuildInfo[nftToken][tokenId];
        } else {
            if (guild.gameGuild != address(0)) {
                if (leasing.lender != address(0)) {
                    if (nftToken == geniPass) {
                        IGENIPass(geniPass).unLockPass(tokenId);
                        IGENIPass(geniPass).setActive(tokenId, false);
                        IERC721(geniPass).transferFrom(msg.sender, address(this), tokenId);
                    } else if (nftToken == gemuniItem) {
                        IGEMUNIItem(geniPass).unLockItem(tokenId);
                        IERC721(gemuniItem).transferFrom(msg.sender, address(this), tokenId);
                    }  else {
                        if (IERC721(nftToken).ownerOf(tokenId) == msg.sender) {
                            if (IERC721(nftToken).getApproved(tokenId) == address(this) || IERC721(nftToken).isApprovedForAll(msg.sender, address(this))) {
                                IERC721(nftToken).transferFrom(msg.sender, address(this), tokenId);
                            } else {
                                revert("Leasing: Need to approve first");
                            }
                        } else {
                            geni.transfer(guild.gameGuild, guild.mortgageAmount);
                        }
                    }
                } else {
                    if (nftToken == geniPass) {
                        IGENIPass(geniPass).unLockPass(tokenId);
                        IGENIPass(geniPass).setActive(tokenId, false);
                        transferNFT(geniPass, tokenId, msg.sender, guild.gameGuild, guild.isTransferWallet);
                    } else if (nftToken == gemuniItem) {
                        IGEMUNIItem(gemuniItem).unLockItem(tokenId);
                        transferNFT(gemuniItem, tokenId, msg.sender, guild.gameGuild, guild.isTransferWallet);
                    }  else {
                        checkTransferNFT(nftToken, tokenId, guild.mortgageAmount, msg.sender, guild.gameGuild, guild.isTransferWallet);
                    }

                }

            } else {
                if (nftToken == geniPass) {
                    IGENIPass(geniPass).unLockPass(tokenId);
                    IGENIPass(geniPass).setActive(tokenId, false);
                    transferNFT(geniPass, tokenId, msg.sender, leasing.lender, leasing.isTransferWallet);
                } else if (nftToken == gemuniItem) {
                    IGEMUNIItem(gemuniItem).unLockItem(tokenId);
                    transferNFT(gemuniItem, tokenId, msg.sender, leasing.lender, leasing.isTransferWallet);
                }  else {
                    checkTransferNFT(nftToken, tokenId, leasing.mortgageAmount, msg.sender, leasing.lender, leasing.isTransferWallet); 
                }
            }
            delete renterInfo[nftToken][tokenId];
        }
        emit FinishRenting(nftToken, tokenId, msg.sender);
    }

    function checkTransferNFT(address nftToken, uint tokenId, uint amount, address user, address to, bool isTransferWallet) internal {
        if (IERC721(nftToken).ownerOf(tokenId) == user) {
            if (IERC721(nftToken).getApproved(tokenId) == address(this) || IERC721(nftToken).isApprovedForAll(user, address(this))) {
                transferNFT(nftToken, tokenId, user, address(this), isTransferWallet);
            } else {
                revert("Leasing: Need to approve first");
            }
        } else {
            geni.transfer(to, amount);
        }
    }

    function finishLeasing(address nftToken, uint[] memory tokenIds) external override {
        for (uint i = 0; i < tokenIds.length; i++) {
            RenterInfo storage renter = renterInfo[nftToken][tokenIds[i]];
            LeasingInfo storage leasing = leasingInfo[nftToken][tokenIds[i]];
            LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenIds[i]];
            require(msg.sender == guild.gameGuild || operators[msg.sender], "Leasing: invalid ");
            require(renter.renter != address(0) || guild.gameGuild != address(0),"GEMUNILending: not found lending info");
            if (msg.sender == guild.gameGuild) {
                guildRetrieveNFT(nftToken, tokenIds[i], renter, guild);
            } else {
                adminRetrieveNFT(nftToken, tokenIds[i], renter, leasing, guild);
            }
        }
    }

    function guildRetrieveNFT(address nftToken, uint tokenId, RenterInfo storage renter, LeasingGuildInfo storage guild) internal {
        uint endLending = renter.startLending + renter.duration ;
        require (block.timestamp > endLending, "GEMUNILending: can not be retrieve");
        if (nftToken == geniPass) {
            IGENIPass(geniPass).unLockPass(tokenId);
            IGENIPass(geniPass).setActive(tokenId, false);
            transferNFT(geniPass, tokenId, msg.sender, address(this), guild.isTransferWallet);
        } else if (nftToken == gemuniItem) {
            IGEMUNIItem(gemuniItem).unLockItem(tokenId);
            transferNFT(gemuniItem, tokenId, msg.sender, address(this), guild.isTransferWallet);
        } else {
            checkTransferNFT(nftToken, tokenId, guild.mortgageAmount, renter.renter, guild.gameGuild, guild.isTransferWallet);
        }
        delete renterInfo[nftToken][tokenId];
    }

    function adminRetrieveNFT(address nftToken,uint tokenId, RenterInfo storage renter, LeasingInfo storage leasing, LeasingGuildInfo storage guild) internal {
        require(leasing.lender != address(0), "Lending: not put on leasing");

        //guild rent pass, retrieve from game guild
        if (renter.renter == address(0) && guild.gameGuild != address(0)) {
            uint endLending = guild.startLending + guild.duration;
            require (block.timestamp > endLending, "GEMUNILending: can not be revoked");
            delete leasingGuildInfo[nftToken][tokenId];
        //guild rent pass, retrieve from renter
        } else if (renter.renter != address(0) && guild.gameGuild != address(0)) {
            uint endLending =  guild.startLending + guild.duration;
            require (block.timestamp > endLending, "GEMUNILending: can not be revoked");
            if (nftToken == geniPass) {
                IGENIPass(geniPass).unLockPass(tokenId);
                IGENIPass(geniPass).setActive(tokenId, false);
                transferNFT(geniPass, tokenId, renter.renter, msg.sender, leasing.isTransferWallet);
            } else if (nftToken == gemuniItem) {
                IGEMUNIItem(gemuniItem).unLockItem(tokenId);
                transferNFT(gemuniItem, tokenId, renter.renter, msg.sender, leasing.isTransferWallet);
            } else {
                checkTransferNFT(nftToken, tokenId, guild.mortgageAmount, renter.renter, leasing.lender, leasing.isTransferWallet);
                // geni.transfer(guild.gameGuild, guild.depositAmount);
                // geni.transfer(treasury, leasing.depositAmount);
            }
            delete renterInfo[nftToken][tokenId];
            delete leasingGuildInfo[nftToken][tokenId];
        //user rent pass, retrieve from renter
        } else if (renter.renter != address(0) && guild.gameGuild == address(0)) {
            uint endLending = renter.startLending + renter.duration;
            require (block.timestamp > endLending, "GEMUNILending: can not be revoked");
            if (nftToken == geniPass) {
                IGENIPass(geniPass).unLockPass(tokenId);
                IGENIPass(geniPass).setActive(tokenId, false);
                transferNFT(geniPass, tokenId, renter.renter, msg.sender, leasing.isTransferWallet);
            } else if (nftToken == gemuniItem) {
                IGEMUNIItem(gemuniItem).unLockItem(tokenId);
                transferNFT(gemuniItem, tokenId, renter.renter,msg.sender, leasing.isTransferWallet);
            } else {
                checkTransferNFT(nftToken, tokenId, leasing.mortgageAmount, renter.renter, leasing.lender, leasing.isTransferWallet);
            }
            delete renterInfo[nftToken][tokenId];
        }
    }

    function transferNFT(address nftToken, uint tokenId, address from, address to, bool isTransferWallet) internal {
        if(isTransferWallet) {
            IERC721(nftToken).transferFrom(from, to, tokenId);
            delete leasingInfo[nftToken][tokenId];
        } else {
            IERC721(nftToken).transferFrom(from, address(this), tokenId);
        }
    }


    function withdrawNFT(address nftToken, uint tokenId) external onlyOperator {
        require(IERC721(nftToken).ownerOf(tokenId) == address(this) && leasingInfo[nftToken][tokenId].lender == address(0), "GEMUNILending: not found token in contract");

        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
        if (nftToken == geniPass) {
            if(IGENIPass(geniPass).isLocked(tokenId)) {
                IGENIPass(geniPass).unLockPass(tokenId);
            }
        } else if (nftToken == gemuniItem) {
            if(IGEMUNIItem(gemuniItem).isLocked(tokenId)) {
                IGEMUNIItem(geniPass).unLockItem(tokenId);
            }
        }
        emit WithdrawPass(nftToken, tokenId);
    }

    function withdrawGeni(uint amount) external onlyOperator {
        require(amount > 0 && amount <= geni.balanceOf(address(this)));
        geni.transfer(treasury, amount);
        emit WithdrawGeni(amount, treasury);
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

interface IGEMUNILeasing {
    struct LeasingInfo {
        address lender;
        bool isTransferWallet;
        uint price;
        uint minDuration;
        uint maxDuration;
        uint mortgageAmount;
    }

    struct LeasingGuildInfo {
        address gameGuild;
        bool isTransferWallet;
        uint price;
        uint minDuration;
        uint maxDuration;
        uint mortgageAmount;
        uint duration;
        uint startLending;
    }


    struct RenterInfo {
        address renter;
        uint duration;
        uint startLending;
    }

    event PutOnLeasing(address nftToken, uint[] indexed tokenId, uint minDuration, uint maxDuration, uint[] pricePerweek, address lender, uint mortgageAmount);
    event RegisterLeasing(address nftToken, uint[] tokenIds, uint duration, uint minDuration, uint maxDuration, uint[] pricePerWeek, uint mortgageAmount, uint rentalPrice);
    event RentPass(address nftToken, uint indexed tokenId, uint price,uint startLending, uint duration);
    event RentMore(address nftToken, uint indexed tokenId, uint newAmount, uint duration);
    event FinishRenting(address nftToken, uint indexed tokenId, address borrower);
    event FinishLeasing(address nftToken, uint[] indexed tokenId, address borrower, address to);
    event UpdateLeasing(address nftToken, uint tokenId, uint newMinDuration, uint newMaxDuration, uint newPricePerSecond, bool newTransferWallet);
    event CancelLeasing(address nftToken, uint indexed tokenId);
    event SetInput(address _gemuniItem, address _geniPass, address _treasury, address _exchange);
    event AddListGameGuild(address[] listGuilds);
    event RemoveFromGuild(address[] listGuilds);

    event WithdrawPass(address nftToken, uint indexed tokenId);
    event WithdrawGeni(uint amount, address treasury);

    function putOnLeasing(address nftToken, uint[] memory tokenId, uint minDuration, uint maxDuration, uint[] memory pricePerWeek, bool transferWallet, uint mortgageAmount) external;
    function registerLeasing(address nftToken, uint[] memory tokenIds, uint duration, uint minDuration, uint maxDuration, uint[] memory pricePerWeek, uint depositAmount, uint rentalPrice) external;
    function rentPass(address nftToken, uint tokenId, uint duration, uint price, bytes memory sig) external;
    function rentMore(address nftToken, uint tokenId, uint amount) external;
    function finishRenting(address nftToken, uint tokenId) external;
    function finishLeasing(address nftToken, uint[] memory tokenId) external;


    function updateLeasing(address nftToken, uint tokenId, uint newMinDuration, uint newMaxDuration, uint newPricePerSecond, bool newTransferWallet) external;
    function cancelLeasing(address nftToken, uint tokenId) external;
    function addListGameGuild(address[] memory users) external;
    function removeFromGuilds(address[] calldata users) external;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IGEMUNIItem is IERC721 {

    /**
     * @notice mint Item
     */
    function burnItem(uint tokenId) external;
    
    /**
     * @notice mint Item
     */
    function mintItem(address _to, uint nouce, bytes memory _signature) external returns(uint tokenId);
    
    function exists() external view returns (uint);

    event ItemCreated(uint indexed tokenId, address indexed owner);
    event SetActive(uint indexed tokenId, bool isActive);
    event LockItem(uint indexed tokenId);
    event UnLockItem(uint indexed tokenId);

    function setActive(uint tokenId, bool _isActive) external;

    function lockItem(uint tokenId) external;

    function unLockItem(uint tokenId) external;

    function permit(address owner, address spender, uint tokenId, bytes memory _signature) external;
    
    function isLocked(uint tokenId) external returns(bool);
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
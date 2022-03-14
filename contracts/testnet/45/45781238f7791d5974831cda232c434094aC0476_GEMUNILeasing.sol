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

    function adminPutOnLeasing(address nftToken, uint tokenId, uint minDuration, uint maxDuration, uint pricePerWeek, bool transferWallet, LeasingType _type) public override onlyOperator {
        require(nftToken != address(0), "Leasing: invalid address");
        require(minDuration > 0 && maxDuration > minDuration && pricePerWeek > 0, "Leasing: invalid input");

        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        leasing.lender = treasury;
        leasing.price = pricePerWeek;
        leasing.minDuration = minDuration * weekPerSecond;
        leasing.maxDuration = maxDuration * weekPerSecond;
        leasing.isTransferWallet = transferWallet;
        leasing.leasingType = _type;

        IERC721(nftToken).transferFrom(msg.sender, address(this), tokenId);

        emit AdminPutOnLeasing(nftToken, tokenId, minDuration, maxDuration, pricePerWeek, _type);
    }

    function guildPutOnLeasing(address nftToken, uint tokenId, uint minDuration, uint maxDuration, uint pricePerWeek, bool transferWallet) external override {
        require(gameGuild[msg.sender], "Lending: not game guild");
        require(nftToken != address(0), "Leasing: invalid address");
        require(minDuration > 0 && maxDuration > minDuration && pricePerWeek > 0, "Leasing: invalid input");

        LeasingGuildInfo storage leasingGuild = leasingGuildInfo[nftToken][tokenId];
        leasingGuild.gameGuild = msg.sender;
        leasingGuild.price = pricePerWeek;
        leasingGuild.minDuration = minDuration * weekPerSecond;
        leasingGuild.maxDuration = maxDuration * weekPerSecond;
        leasingGuild.isTransferWallet = transferWallet;

        IERC721(nftToken).transferFrom(msg.sender, address(this), tokenId);
        
        emit GuildPutOnLeasing(nftToken, tokenId, minDuration, maxDuration, pricePerWeek);
    }

    function guildRegisteredLeasing(address nftToken, uint[] memory tokenIds, uint duration, uint minDuration, uint maxDuration, uint pricePerWeek, uint depositAmount, uint rentalPrice) external override {
        require(gameGuild[msg.sender], "Lending: not game guild");
        require(tokenIds.length >= minPasses, "Leasing: invalid number of passes");
        uint totalRental;
        if (nftToken != geniPass && nftToken != gemuniItem) {
            require(depositAmount > 0, "Leasing: invalid deposit amount");
        } else {
            require(depositAmount == 0, "Leasing: invalid deposit amount");
        }
        for(uint i = 0; i < tokenIds.length; i++) {
            LeasingInfo storage leasing = leasingInfo[nftToken][tokenIds[i]];
            LeasingGuildInfo storage leasingGuild = leasingGuildInfo[nftToken][tokenIds[i]];
            uint min = leasing.minDuration;
            uint max = leasing.maxDuration;
            totalRental  += leasing.price;

            require(leasing.lender != address(0), "Leasing: not put on leasing");
            require(leasing.leasingType == LeasingType.GameGuild, "Leasing: not for game guild");
            require(leasingGuild.gameGuild == address(0),"Leasing: already registered");
            require(duration >= min && duration <= max, "Leasing: invalid duration");

            require(minDuration > 0 && minDuration < min  && maxDuration > minDuration && maxDuration < max && pricePerWeek > leasing.price, "Leasing: invalid input");

            leasingGuild.gameGuild = msg.sender;
            leasingGuild.duration = duration * weekPerSecond;

            leasingGuild.price = pricePerWeek;
            leasingGuild.minDuration = minDuration * weekPerSecond;
            leasingGuild.maxDuration = maxDuration * weekPerSecond;
            leasingGuild.isTransferWallet = leasing.isTransferWallet;
            leasingGuild.depositAmount = depositAmount;
        }
        totalRental *= duration;
        uint totalGeniAmount = convertPrice(totalRental);
        require(rentalPrice == totalRental, "Leasing: invalid price");
        geni.transferFrom(msg.sender, treasury, totalGeniAmount);
        emit GuildRegisteredLeasing(nftToken, tokenIds, duration, minDuration, maxDuration, pricePerWeek, depositAmount, rentalPrice);
    }

    function putOnLeasingBatch(CreateLeasingPasses[] memory input) external {
        for (uint i = 0; i < input.length; i++) {
            adminPutOnLeasing(input[i].nftToken, input[i].tokenId, input[i].minDuration, input[i].maxDuration, input[i].pricePerSecond, input[i].transferWallet, input[i]._type);
        }
    }

    function updateLeasingPass(address nftToken, uint tokenId, uint newMinDuration, uint newMaxDuration, uint newPricePerSecond, bool newTransferWallet) external override {
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
        emit UpdateLeasingPass(nftToken, tokenId, newMinDuration, newMaxDuration, newPricePerSecond, newTransferWallet);
    }
    
    function removeFromLending(address nftToken, uint tokenId) external override {
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
 
        emit RemoveFromLending(nftToken, tokenId);
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

    function lendPass(address nftToken, uint tokenId, uint duration, uint price, bytes memory sig) external override {
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        RenterInfo storage renter = renterInfo[nftToken][tokenId];
        require(renter.renter == address(0), "Leasing: already rented");
        duration = duration * weekPerSecond;
        uint rentalPriceGeni;
        if (leasing.leasingType == LeasingType.GameGuild && guild.gameGuild != address(0) || leasing.lender == address(0) && guild.gameGuild != address(0)) {
            rentalPriceGeni = rentPassFromGameGuild(guild, duration, price);
        } else {
            rentalPriceGeni = rentPassFromAdmin(leasing, duration, price);
        }
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);

        if (nftToken == geniPass) {

            
            IGENIPass(geniPass).permit(msg.sender, address(this), tokenId, sig);

            IGENIPass(geniPass).setActive(tokenId, true);

            if(!IGENIPass(geniPass).isLocked(tokenId)) {

                IGENIPass(geniPass).lockPass(tokenId);
            }
        } else {
            geni.transferFrom(msg.sender, address(this), leasing.depositAmount);
        }
        renter.renter = msg.sender;
        renter.startLending = block.timestamp;
        renter.duration = duration;
        emit LendPass(nftToken, tokenId, rentalPriceGeni, renter.startLending, duration);
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


    function increaseMortgage(address nftToken, uint amount, uint tokenId) external override {
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        RenterInfo storage renter = renterInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        require(amount > 0,"GEMUNILending: invalid amount");
        uint caculatedDuration;
        if (leasing.leasingType == LeasingType.GameGuild && msg.sender == renter.renter) {
            caculatedDuration =  amount / guild.price;
            renter.addedDuration += caculatedDuration;
            
        } else if (leasing.leasingType == LeasingType.GameGuild && msg.sender == guild.gameGuild || leasing.leasingType == LeasingType.User && msg.sender == renter.renter) {
            caculatedDuration =  amount / leasing.price;

            if (msg.sender == guild.gameGuild) {
                guild.addedDuration += caculatedDuration;
            } else {
                renter.addedDuration += caculatedDuration;
            }

        } else {
            revert ("Leasing: invalid sender");
        }

        geni.transferFrom(msg.sender, address(this), amount);


        emit IncreaseMortgage(nftToken, tokenId, amount);
    }

    function userReturnPass(address nftToken, uint tokenId) external override {
        RenterInfo storage renter = renterInfo[nftToken][tokenId];
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        if (msg.sender == guild.gameGuild) {
            require(renter.renter == address(0), "Leasing: need to retrieve pass form user");
            guildReturnNFT(leasing, guild);
            delete leasingGuildInfo[nftToken][tokenId];
        } else if (msg.sender == renter.renter) {
            userReturnNFT(renter, leasing, guild);
            delete renterInfo[nftToken][tokenId];
        } else {
            revert("Leasing: invalid lender");
        }
        if (nftToken == geniPass) {
            IGENIPass(geniPass).unLockPass(tokenId);
            IGENIPass(geniPass).setActive(tokenId, false);
        } else if (nftToken == gemuniItem) {
            IGEMUNIItem(geniPass).unLockItem(tokenId);
            IGEMUNIItem(geniPass).setActive(tokenId, false);
        }  else {
            if (msg.sender == renter.renter && leasing.lender == address(0)) {
                geni.transfer(msg.sender, guild.depositAmount);
            } else if (msg.sender == renter.renter && guild.gameGuild == address(0)) {
                geni.transfer(msg.sender, leasing.depositAmount);
            }
        }
        transferNFT(nftToken, tokenId, msg.sender, address(this));

        emit UserReturnPass(nftToken, tokenId, msg.sender);
    }

    function userReturnNFT(RenterInfo storage renter, LeasingInfo storage leasing, LeasingGuildInfo storage guild) internal {
        uint endLending = renter.startLending + renter.duration + renter.addedDuration;
        if (block.timestamp > endLending) {
            uint debtAmount;
            uint addedAmount;
            if (leasing.leasingType == LeasingType.GameGuild) {
                debtAmount = (block.timestamp - endLending) * guild.price;
                if (renter.addedDuration > 0) {
                    addedAmount = renter.addedDuration *  guild.price;
                    geni.transfer(guild.gameGuild, addedAmount);
                }
                geni.transferFrom(msg.sender, guild.gameGuild, debtAmount);
            } else {
                debtAmount = (block.timestamp - endLending) * leasing.price;
                if (renter.addedDuration > 0) {
                    addedAmount = renter.addedDuration *  leasing.price;
                    geni.transfer(leasing.lender, addedAmount);
                }
                geni.transferFrom(msg.sender, leasing.lender, debtAmount);
            }
        } else if (block.timestamp < endLending) {
            uint returnAmount;
            if (leasing.leasingType == LeasingType.GameGuild) {
                if (renter.addedDuration == 0) {
                    returnAmount = 0;
                } else {
                    returnAmount = block.timestamp < (renter.startLending + renter.duration) ? renter.addedDuration * guild.price : (endLending - block.timestamp) * guild.price;
                    if (renter.addedDuration > 0 && block.timestamp > (renter.startLending + renter.duration)) {
                        uint addedAmount = (renter.addedDuration *  leasing.price) - returnAmount;
                        geni.transfer(guild.gameGuild, addedAmount);
                    }
                }
            } else {
                if (renter.addedDuration == 0) {
                    returnAmount = 0;
                } else {
                    returnAmount = block.timestamp < (renter.startLending + renter.duration) ? renter.addedDuration * leasing.price : (endLending - block.timestamp) * leasing.price;
                    if (renter.addedDuration > 0 && block.timestamp > (renter.startLending + renter.duration)) {
                        uint addedAmount = (renter.addedDuration *  leasing.price) - returnAmount;
                        geni.transfer(leasing.lender, addedAmount);
                    }
                }
            }
            if (returnAmount > 0) {
                geni.transfer(msg.sender, returnAmount);
            }
        }
    }

    function guildReturnNFT(LeasingInfo storage leasing, LeasingGuildInfo storage guild) internal {
        uint endLending = guild.startLending + guild.duration + guild.addedDuration;
        if (block.timestamp > endLending) {
            uint debtAmount = (block.timestamp - endLending) * leasing.price;
            if (guild.addedDuration > 0) {
                uint addedAmount = guild.addedDuration *  leasing.price;
                geni.transfer(guild.gameGuild, addedAmount);
            }
            geni.transferFrom(msg.sender, treasury, debtAmount);
        } else if (block.timestamp < endLending) {
            uint returnAmount;
            if (guild.addedDuration == 0) {
                returnAmount = 0;
            } else {
                returnAmount = block.timestamp < (guild.startLending + guild.duration) ? guild.addedDuration * guild.price : (endLending - block.timestamp) * guild.price;
                if (guild.addedDuration > 0 && block.timestamp > (guild.startLending + guild.duration)) {
                    uint addedAmount = (guild.addedDuration *  leasing.price) - returnAmount;
                    geni.transfer(leasing.lender, addedAmount);
                }
            }
            if (returnAmount > 0) {
                geni.transfer(msg.sender, returnAmount);
            }
        }
    }

    function guildRetrieveNFT(address nftToken, uint tokenId, address to) public override {
        RenterInfo storage renter = renterInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        require(renter.renter != address(0), "Leasing: not found lending info");
        uint endLending = renter.startLending + renter.duration + renter.addedDuration;
        require (block.timestamp > endLending, "GEMUNILending: can not be retrieve");
        uint currentInterest = renter.addedDuration * guild.price;
        if (nftToken == geniPass) {
            IGENIPass(geniPass).unLockPass(tokenId);
            IGENIPass(geniPass).setActive(tokenId, false);
            geni.transfer(guild.gameGuild, currentInterest);
            transferNFT(nftToken, tokenId, msg.sender, address(this));
        } else if (nftToken == gemuniItem) {
            IGEMUNIItem(gemuniItem).unLockItem(tokenId);
            IGEMUNIItem(gemuniItem).setActive(tokenId, false);
            geni.transfer(guild.gameGuild, currentInterest);
            transferNFT(nftToken, tokenId, msg.sender, address(this));
        } else {
            geni.transfer(guild.gameGuild, currentInterest + guild.depositAmount);
        }
        delete renterInfo[nftToken][tokenId];
        emit GuildRetrieveNFT(nftToken, tokenId, renter.renter, to);
    }

    function adminRetrieveNFT(address nftToken,uint tokenId, address to) public override onlyOperator {
        RenterInfo storage renter = renterInfo[nftToken][tokenId];
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        LeasingGuildInfo storage guild = leasingGuildInfo[nftToken][tokenId];
        require(leasing.lender != address(0), "Lending: not found lending info");
        require(renter.renter != address(0) || guild.gameGuild != address(0),"GEMUNILending: not found lending info");

        //guild rent pass, retrieve from game guild
        if (renter.renter == address(0) && guild.gameGuild != address(0)) {
            uint endLending = guild.addedDuration > 0 ? guild.startLending + guild.duration + guild.addedDuration : guild.startLending + guild.duration;
            require (block.timestamp > endLending, "GEMUNILending: can not be revoked");
            if (guild.addedDuration > 0) {
                uint currentInterest = guild.addedDuration * leasing.price;
                geni.transfer(treasury, currentInterest);
            }
            delete leasingGuildInfo[nftToken][tokenId];
        //guild rent pass, retrieve from renter
        } else if (renter.renter != address(0) && guild.gameGuild != address(0)) {
            uint endLending = guild.addedDuration > 0 ? guild.startLending + guild.duration + guild.addedDuration : guild.startLending + guild.duration;
            require (block.timestamp > endLending, "GEMUNILending: can not be revoked");
            if (renter.addedDuration > 0) {
                uint currentInterestUser = renter.addedDuration * guild.price;
                geni.transfer(guild.gameGuild, currentInterestUser);
            }
            if (guild.addedDuration > 0) {
                uint currentInterestGuild = guild.addedDuration * leasing.price;
                geni.transfer(treasury, currentInterestGuild);
            }
            if (nftToken == geniPass) {
                IGENIPass(geniPass).unLockPass(tokenId);
                IGENIPass(geniPass).setActive(tokenId, false);
                transferNFT(geniPass, tokenId, renter.renter, to);
            } else if (nftToken == gemuniItem) {
                IGEMUNIItem(gemuniItem).unLockItem(tokenId);
                IGEMUNIItem(gemuniItem).setActive(tokenId, false);
                transferNFT(gemuniItem, tokenId, renter.renter, to);
            } else {
                geni.transfer(guild.gameGuild, guild.depositAmount);
                geni.transfer(treasury, leasing.depositAmount);
            }
            delete renterInfo[nftToken][tokenId];
            delete leasingGuildInfo[nftToken][tokenId];
        //user rent pass, retrieve from renter
        } else if (renter.renter != address(0) && leasing.leasingType == LeasingType.User) {
            uint endLending = renter.addedDuration > 0 ? renter.startLending + renter.duration + renter.addedDuration : renter.startLending + renter.duration;
            require (block.timestamp > endLending, "GEMUNILending: can not be revoked");
            if (renter.addedDuration > 0) {
                uint currentInterest = renter.addedDuration * leasing.price;
                geni.transfer(treasury, currentInterest);
            }
            if (nftToken == geniPass) {
                IGENIPass(geniPass).unLockPass(tokenId);
                IGENIPass(geniPass).setActive(tokenId, false);
                transferNFT(geniPass, tokenId, renter.renter, to);
            } else if (nftToken == gemuniItem) {
                IGEMUNIItem(gemuniItem).unLockItem(tokenId);
                IGEMUNIItem(gemuniItem).setActive(tokenId, false);
                transferNFT(gemuniItem, tokenId, renter.renter, to);
            } else {
                geni.transfer(treasury, leasing.depositAmount);
            }
            delete renterInfo[nftToken][tokenId];
        }

        emit AdminRetrievePass(nftToken ,tokenId, renter.renter, to);
    }

    // function revokeListPasses(address nftToken, uint[] memory tokenIds, address to) external {
    //     for(uint i = 0; i < tokenIds.length; i++) {
    //         adminRevokePass(nftToken, tokenIds[i], to);
    //     }
    // }

    function transferNFT(address nftToken, uint tokenId, address from, address to) internal {
        LeasingInfo storage leasing = leasingInfo[nftToken][tokenId];
        if(leasing.isTransferWallet) {
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

    // function withdrawGeni(uint amount) external onlyOperator {
    //     require(amount > 0 && amount <= geni.balanceOf(address(this)));
    //     geni.transfer(treasury, amount);
    //     emit WithdrawGeni(amount, treasury);
    // }
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
        uint price;
        uint depositAmount;
        uint minDuration;
        uint maxDuration;
        bool isTransferWallet;
        LeasingType leasingType;
    }

    struct LeasingGuildInfo {
        address gameGuild;
        uint price;
        uint depositAmount;
        uint minDuration;
        uint maxDuration;
        bool isTransferWallet;
        uint duration;
        uint startLending;
        uint addedDuration;
    }


    struct RenterInfo {
        address renter;
        uint duration;
        uint addedDuration;
        uint startLending;
    }

    struct CreateLeasingPasses {
        address nftToken;
        uint tokenId;
        uint minDuration;
        uint maxDuration;
        uint pricePerSecond;
        bool transferWallet;
        LeasingType _type;
        address gameGuild;
    }

    enum LeasingType {User, GameGuild}

    event AdminPutOnLeasing(address nftToken, uint indexed tokenId, uint minDuration, uint maxDuration, uint pricePerSecond, LeasingType leasingType);
    event GuildPutOnLeasing(address nftToken, uint indexed tokenId, uint minDuration, uint maxDuration, uint pricePerSecond);
    event GuildRegisteredLeasing(address nftToken, uint[] tokenIds, uint duration, uint minDuration, uint maxDuration, uint pricePerWeek, uint depositAmount, uint rentalPrice);
    event LendPass(address nftToken, uint indexed tokenId, uint price,uint startLending, uint duration);
    event UpdateLeasingPass(address nftToken, uint tokenId, uint newMinDuration, uint newMaxDuration, uint newPricePerSecond, bool newTransferWallet);
    event RemoveFromLending(address nftToken, uint indexed tokenId);
    event SetInput(address _gemuniItem, address _geniPass, address _treasury, address _exchange);
    event AddListGameGuild(address[] listGuilds);
    event RemoveFromGuild(address[] listGuilds);

    event IncreaseMortgage(address nftToken, uint indexed tokenId, uint newAmount);
    event UserReturnPass(address nftToken, uint indexed tokenId, address borrower);
    event AdminRetrievePass(address nftToken, uint indexed tokenId, address borrower, address to);
    event GuildRetrieveNFT(address nftToken, uint indexed tokenId, address borrower, address to);

    event WithdrawPass(address nftToken, uint indexed tokenId);
    event WithdrawGeni(uint amount, address treasury);

    function adminPutOnLeasing(address nftToken, uint tokenId, uint minDuration, uint maxDuration, uint pricePerWeek, bool transferWallet, LeasingType _type) external;
    function guildPutOnLeasing(address nftToken, uint tokenId, uint minDuration, uint maxDuration, uint pricePerWeek, bool transferWallet) external;
    function guildRegisteredLeasing(address nftToken, uint[] memory tokenIds, uint duration, uint minDuration, uint maxDuration, uint pricePerWeek, uint depositAmount, uint rentalPrice) external;
    function updateLeasingPass(address nftToken, uint tokenId, uint newMinDuration, uint newMaxDuration, uint newPricePerSecond, bool newTransferWallet) external;
    function removeFromLending(address nftToken, uint tokenId) external;
    function addListGameGuild(address[] memory users) external;
    function removeFromGuilds(address[] calldata users) external;
    function lendPass(address nftToken, uint tokenId, uint duration, uint price, bytes memory sig) external;
    function increaseMortgage(address nftToken, uint amount, uint tokenId) external;
    function userReturnPass(address nftToken, uint tokenId) external;
    function guildRetrieveNFT(address nftToken, uint tokenId, address to) external;
    function adminRetrieveNFT(address nftToken,uint tokenId, address to) external;
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
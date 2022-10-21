/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// File: LexeonPackagesPriceInterface.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.6.0;

interface ILexeonPackagesPrice {
    function getPrice(uint8,uint8) external pure returns(uint256);
}
// File: lexeonsystemv2.sol

/**
  *  Lexeon System smart contract
  *
  *  888                                                  
  *  888                                                  
  *  888                                                  
  *  888      .d88b.  888  888  .d88b.   .d88b.  88888b.  
  *  888     d8P  Y8b `Y8bd8P' d8P  Y8b d88""88b 888 "88b 
  *  888     88888888   X88K   88888888 888  888 888  888 
  *  888     Y8b.     .d8""8b. Y8b.     Y88..88P 888  888 
  *  88888888 "Y8888  888  888  "Y8888   "Y88P"  888  888 
  *  
 */

pragma solidity >=0.4.23 <0.6.0;


contract LexeonSystemV2 {
    address public owner;
    uint8 public adminCommissionRate;
    uint8 public ALPHA_SIGMA_LEVELS;
    ILexeonPackagesPrice packagePrices;
    enum IncomeType { DIRECT, INDIRECT, ADMIN_INCOME }
    struct User {
        uint256 id;
        address referrer;
        uint partnersCount;
        mapping(uint8 => bool) alphaLearningPackage;
        mapping(uint8 => bool) sigmaLearningPackage;
        mapping(uint8 => bool) omegaLearningPackage;
        mapping(uint8 => Alpha) alphaMatrix;
        mapping(uint8 => Sigma) sigmaMatrix;
        mapping(uint8 => Omega) omegaMatrix;
    }
    struct Alpha {
        address currentReferrer;
        address[] referrals;
        uint256 reinvestCount;
    }
    struct Sigma {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        address[] thirdLevelReferrals;
        bool isReinvestment;
        uint256 reinvestCount;
    }
    struct Omega {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool isReinvestment;
        uint256 reinvestCount;
    }
    mapping(address => User) users;
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 packageNum);
    event NewUserPlace(uint256 userId, uint256 referrerId, uint8 matrix, uint8 packageNum, uint8 place, uint256 amount, IncomeType incomeType);
    event ReceivedEarning(uint256 userId, uint256 indexed receivedFrom, uint256 referralId, uint256 place, uint8 slotId,uint8 matrix, address receiverAddress,uint256 amount, IncomeType incomeType);
    modifier onlyOwner () {
        require(msg.sender == owner, "LSE01");
        _;
    }
    modifier userMustExist (address user) {
        require(isUserExists(user), "LSE02");
        _;
    }
    modifier registrationCost () {
        uint256 commission = ((packagePrices.getPrice(1,1) + packagePrices.getPrice(2,1) + packagePrices.getPrice(3,1)) * adminCommissionRate) / 100;
        require(msg.value == (packagePrices.getPrice(1,1) + packagePrices.getPrice(2,1) + packagePrices.getPrice(3,1)) + commission, "LS03");
        _;
    }
    modifier isPackageExist (uint8 packageNum) {
        require(packageNum >= 1 && packageNum <= ALPHA_SIGMA_LEVELS, "LSE04");
        _;
    }
    modifier isFirstTime () {
        require(address(0x0) == owner, "You can not call it again!");
        _;
    }
    function transferOwnerShip (address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    function initialiser (address _owner, address _packagePriceAddress, uint8 _adminCommissionRate, uint8 alphaSigmaLevels, uint256 _partnersCount) public isFirstTime {
        owner = _owner;
        adminCommissionRate = _adminCommissionRate;
        ALPHA_SIGMA_LEVELS = alphaSigmaLevels;
        packagePrices = ILexeonPackagesPrice(_packagePriceAddress);
        users[owner] = User({
            id : 1,
            referrer: owner,
            partnersCount: _partnersCount
        });
        for (uint8 i = 1; i <= ALPHA_SIGMA_LEVELS; i++) {
            if(i <= 8) users[owner].omegaLearningPackage[i] = true;
            users[owner].alphaLearningPackage[i] = true;
            users[owner].sigmaLearningPackage[i] = true;
        }
    }
    function userRegistration (address referrerAddress, uint256 userId) public payable userMustExist(referrerAddress) registrationCost{
        require(!isUserExists(msg.sender), "LSE05");
        uint32 size;
        address _addr = msg.sender;
        assembly {
            size := extcodesize(_addr)
        }
        require(size == 0, "cannot be a contract");
        users[msg.sender] = User({
            id: userId,
            referrer: referrerAddress,
            partnersCount: 0
        });
        users[referrerAddress].partnersCount++;
        buyAlphaPackage(1); buySigmaPackage(1); buyOmegaPackage(1);
        emit Registration(msg.sender, referrerAddress, users[msg.sender].id, users[referrerAddress].id);
    }
    function findAdminCommission (uint256 _amount) pure private returns(uint256){
        return (_amount * 3)/100;
    }
    function buyAlphaPackage (uint8 packageNum) public payable userMustExist(msg.sender) isPackageExist(packageNum) {
        require(!users[msg.sender].alphaLearningPackage[packageNum], "LSE06");
        users[msg.sender].alphaLearningPackage[packageNum] = true;   
        users[msg.sender].alphaMatrix[packageNum].currentReferrer = findUplineSponser(msg.sender, packageNum, 1);
        updateAlphaPackage(msg.sender, users[msg.sender].alphaMatrix[packageNum].currentReferrer, packageNum);
        sendCommission(users[owner].id, users[msg.sender].id, users[users[msg.sender].referrer].id, 0, packageNum, 1, owner, findAdminCommission(packagePrices.getPrice(1,packageNum)));
    }
    function updateAlphaPackage (address userAddress, address referrerAddress, uint8 packageNum) private {
        if (users[referrerAddress].alphaMatrix[packageNum].referrals.length < 2) {
            users[referrerAddress].alphaMatrix[packageNum].referrals.push(userAddress);
            uint8 place = uint8(users[referrerAddress].alphaMatrix[packageNum].referrals.length);
            emit NewUserPlace(users[referrerAddress].id, users[userAddress].id, 1, packageNum, place, packagePrices.getPrice(1,packageNum), IncomeType.DIRECT);
            return sendCommission(users[referrerAddress].id, users[userAddress].id, users[users[userAddress].referrer].id, place, packageNum, 1, referrerAddress, packagePrices.getPrice(1,packageNum));
        }
        emit NewUserPlace(users[referrerAddress].id, users[userAddress].id,1, packageNum, 3, packagePrices.getPrice(1,packageNum), IncomeType.DIRECT);
        users[referrerAddress].alphaMatrix[packageNum].referrals = new address[](0);
        address upliner = findUplineSponser(referrerAddress, packageNum, 1);
        sendCommission(users[upliner].id, users[userAddress].id, users[users[userAddress].referrer].id,3, packageNum, 1,upliner,packagePrices.getPrice(1,packageNum));
        users[referrerAddress].alphaMatrix[packageNum].reinvestCount++;
        emit Reinvest(referrerAddress, upliner, userAddress, 1, packageNum);
    }
    function buySigmaPackage (uint8 packageNum) public payable userMustExist(msg.sender) isPackageExist(packageNum){
        require(!users[msg.sender].sigmaLearningPackage[packageNum], "LSE06");
        users[msg.sender].sigmaLearningPackage[packageNum] = true;
        address referrerAddress = findUplineSponser(msg.sender, packageNum,3);
        uint8 place = updateSigmaPackage(msg.sender, referrerAddress, packageNum);
        sendSigmaCommissions(msg.sender, referrerAddress,packageNum, place);
        uint256 _amount = packagePrices.getPrice(3,packageNum);
        sendCommission(users[owner].id, users[msg.sender].id, users[users[msg.sender].referrer].id, 0, packageNum, 3, owner, findAdminCommission(_amount));
    }
    function updateSigmaPackage (address userAddress, address referrerAddress, uint8 packageNum) private returns(uint8) {
        uint8 place;
        if(users[referrerAddress].sigmaMatrix[packageNum].firstLevelReferrals.length < 2) {
            users[referrerAddress].sigmaMatrix[packageNum].firstLevelReferrals.push(userAddress);
            users[userAddress].sigmaMatrix[packageNum].currentReferrer = referrerAddress;
            place = uint8(users[referrerAddress].sigmaMatrix[packageNum].firstLevelReferrals.length);
            emit NewUserPlace(users[referrerAddress].id, users[userAddress].id, 3, packageNum, place, packagePrices.getPrice(3,packageNum), IncomeType.DIRECT);
        } else if(users[referrerAddress].sigmaMatrix[packageNum].secondLevelReferrals.length < 4) {
            users[referrerAddress].sigmaMatrix[packageNum].secondLevelReferrals.push(userAddress);
            users[userAddress].sigmaMatrix[packageNum].currentReferrer = referrerAddress;
            place = uint8(users[referrerAddress].sigmaMatrix[packageNum].secondLevelReferrals.length+2);
            emit NewUserPlace(users[referrerAddress].id, users[userAddress].id,3, packageNum, place, packagePrices.getPrice(3,packageNum), IncomeType.INDIRECT);
        } else if(users[referrerAddress].sigmaMatrix[packageNum].thirdLevelReferrals.length < 8) {
            users[referrerAddress].sigmaMatrix[packageNum].thirdLevelReferrals.push(userAddress);
            users[userAddress].sigmaMatrix[packageNum].currentReferrer = referrerAddress;
            place = uint8(users[referrerAddress].sigmaMatrix[packageNum].thirdLevelReferrals.length+6);
            emit NewUserPlace(users[referrerAddress].id, users[userAddress].id, 3, packageNum, place, packagePrices.getPrice(3,packageNum), IncomeType.INDIRECT);
            if(users[referrerAddress].sigmaMatrix[packageNum].thirdLevelReferrals.length == 8) {
                reinvestSigma(referrerAddress, packageNum);
                users[referrerAddress].sigmaMatrix[packageNum].isReinvestment = true;
                emit Reinvest(userAddress, referrerAddress, referrerAddress, 2, packageNum);
            }
        }
        return place;
    }
    function reinvestSigma(address investor, uint8 packageNum) private {
        users[investor].sigmaMatrix[packageNum].firstLevelReferrals = new address[](0);
        users[investor].sigmaMatrix[packageNum].secondLevelReferrals = new address[](0);
        users[investor].sigmaMatrix[packageNum].thirdLevelReferrals = new address[](0);
        users[investor].sigmaMatrix[packageNum].reinvestCount++;
    }
    function sendSigmaCommissions (address userAddress, address firstLevelCommissionReceiver,uint8 packageNum, uint8 place) private {
        uint256 sigmaPkgPrice = packagePrices.getPrice(3,packageNum);
        address secondLevelCommissionReceiver = findUplineSponser(firstLevelCommissionReceiver, packageNum,3);
        address thirdLevelCommissionReceiver = findUplineSponser(secondLevelCommissionReceiver, packageNum,3);
        if(users[userAddress].sigmaMatrix[packageNum].isReinvestment) {
            address sponser = findUplineSponser(firstLevelCommissionReceiver, packageNum, 3);
            sendCommission(users[sponser].id,users[userAddress].id,users[users[userAddress].referrer].id,place,packageNum,3,findUplineSponser(sponser, packageNum, 3), sigmaPkgPrice);
            users[userAddress].sigmaMatrix[packageNum].isReinvestment = false;
        } else {
            if(firstLevelCommissionReceiver == owner) {
                sendCommission(
                    users[firstLevelCommissionReceiver].id,
                    users[userAddress].id,
                    users[users[userAddress].referrer].id,
                    place,
                    packageNum,
                    3,
                    firstLevelCommissionReceiver,
                    sigmaPkgPrice
                );
                return;
            }
            sendCommission(
                users[firstLevelCommissionReceiver].id,
                users[userAddress].id,
                users[users[userAddress].referrer].id,
                place, packageNum,3, 
                firstLevelCommissionReceiver, 
                (sigmaPkgPrice * 20) / 100
            );
            if(secondLevelCommissionReceiver == owner) {
                sendCommission(
                    users[secondLevelCommissionReceiver].id,
                    users[userAddress].id,
                    users[users[userAddress].referrer].id,
                    place,
                    packageNum,
                    3,
                    secondLevelCommissionReceiver, (sigmaPkgPrice * 80) / 100
                );
                return;
            }
            sendCommission(
                users[secondLevelCommissionReceiver].id,
                users[userAddress].id,
                users[users[userAddress].referrer].id,
                place,
                packageNum,
                3,
                secondLevelCommissionReceiver, 
                (sigmaPkgPrice * 30) / 100
            );
            sendCommission(
                users[thirdLevelCommissionReceiver].id,
                users[userAddress].id,
                users[users[userAddress].referrer].id,
                place,
                packageNum,
                3,
                thirdLevelCommissionReceiver, (sigmaPkgPrice * 50) / 100
            );
        }
    }
    function buyOmegaPackage (uint8 packageNum) public userMustExist(msg.sender) payable {
        require(!users[msg.sender].omegaLearningPackage[packageNum], "LSE06");
        users[msg.sender].omegaLearningPackage[packageNum] = true;
        address omegaUpliner = findUplineSponser(msg.sender, packageNum,2);
        uint8 place = updateOmegaPackage(msg.sender, omegaUpliner, packageNum);
        sendOmegaCommission(msg.sender,omegaUpliner,packageNum, place);
        sendCommission(users[owner].id, users[msg.sender].id, users[users[msg.sender].referrer].id, 0, packageNum, 2, owner, findAdminCommission(packagePrices.getPrice(2,packageNum)));
    }
    function updateOmegaPackage(address userAddress, address referrerAddress, uint8 packageNum) private returns(uint8){
        if(users[referrerAddress].omegaMatrix[packageNum].firstLevelReferrals.length < 2) {
            users[referrerAddress].omegaMatrix[packageNum].firstLevelReferrals.push(userAddress);
            users[userAddress].omegaMatrix[packageNum].currentReferrer = referrerAddress;
            uint8 place = uint8(users[referrerAddress].omegaMatrix[packageNum].firstLevelReferrals.length);
            emit NewUserPlace(users[referrerAddress].id, users[userAddress].id, 2, packageNum, place, packagePrices.getPrice(2,packageNum), IncomeType.INDIRECT);
            return place;
        } else if (users[referrerAddress].omegaMatrix[packageNum].secondLevelReferrals.length < 4) {
            users[referrerAddress].omegaMatrix[packageNum].secondLevelReferrals.push(userAddress);
            users[userAddress].omegaMatrix[packageNum].currentReferrer = referrerAddress;
            uint8 place = uint8(users[referrerAddress].omegaMatrix[packageNum].secondLevelReferrals.length+2);
            emit NewUserPlace(users[referrerAddress].id, users[userAddress].id, 2, packageNum, place, packagePrices.getPrice(2,packageNum), IncomeType.DIRECT);
            if(users[referrerAddress].omegaMatrix[packageNum].secondLevelReferrals.length == 4) {
                reinvestOmega(referrerAddress, packageNum);
                users[referrerAddress].omegaMatrix[packageNum].isReinvestment = true;
                emit Reinvest(userAddress,referrerAddress,referrerAddress,3,packageNum);
            }
            return place;
        }
    }
    function reinvestOmega(address investor, uint8 packageNum) private {
        users[investor].omegaMatrix[packageNum].firstLevelReferrals = new address[](0);
        users[investor].omegaMatrix[packageNum].secondLevelReferrals = new address[](0);
        users[investor].omegaMatrix[packageNum].reinvestCount++;
    }
    function sendOmegaCommission(address userAddress, address referrarAddress, uint8 packageNum, uint8 place) private {
        if(users[referrarAddress].omegaMatrix[packageNum].isReinvestment) {
            address sponser = findUplineSponser(referrarAddress, packageNum, 3);
            sendCommission(
                users[sponser].id,
                users[userAddress].id,
                users[referrarAddress].id,
                place,
                packageNum,
                2,
                sponser, 
                packagePrices.getPrice(2,packageNum)
            );
            users[referrarAddress].omegaMatrix[packageNum].isReinvestment = false;
        } else {
            address commissionReceiver = findUplineSponser(userAddress, packageNum, 2);
            if(place <= 2) {
                address newCommissionReceiver = findUplineSponser(commissionReceiver, packageNum, 2);
                sendCommission(
                    users[newCommissionReceiver].id,
                    users[userAddress].id,
                    users[users[userAddress].referrer].id,
                    place,
                    packageNum,
                    2,
                    newCommissionReceiver, packagePrices.getPrice(2,packageNum)
                );
                return;
            }
            sendCommission(
                users[commissionReceiver].id,
                users[userAddress].id,
                users[users[userAddress].referrer].id,
                place,
                packageNum,
                2,
                commissionReceiver, 
                packagePrices.getPrice(2,packageNum)
            );
            return;
        }
    }
    function isUserExists (address user) public view returns (bool) {
        // return false;
        return (users[user].id != 0);
    }
    function findUplineSponser(address userAddress, uint8 packageNum, uint8 matrix) public view returns(address) {
        while(true) {
            if(matrix == 1) {
                if (users[users[userAddress].referrer].alphaLearningPackage[packageNum]) {
                    return users[userAddress].referrer;
                }
            } else if (matrix == 3) {
                if (users[users[userAddress].referrer].sigmaLearningPackage[packageNum]) {
                    return users[userAddress].referrer;
                }
            } else if (matrix == 2) {
                if (users[users[userAddress].referrer].omegaLearningPackage[packageNum]) {
                    return users[userAddress].referrer;
                }
            }
            userAddress = users[userAddress].referrer;
        }
    }
    function sendCommission(uint256 userId, uint256 receivedFrom, uint256 referralId, uint8 place, uint8 slotId, uint8 matrix,address userAddress, uint256 amount) private {
        address(uint160(userAddress)).transfer(amount);
        IncomeType incomeType = IncomeType.INDIRECT;
        if(users[msg.sender].referrer == userAddress) incomeType = IncomeType.DIRECT;
        if(place == 0) incomeType = IncomeType.ADMIN_INCOME;
        emit ReceivedEarning(userId, receivedFrom, referralId, place, slotId, matrix, userAddress, amount, incomeType);
    }
    function addUserStatic(address userAddress, uint256 _userId, address _referrerAddress, uint256 _partnersCount, uint8 alphaPkg, uint8 omegaPkg, uint8 sigmaPkg, address alphaCurrentReferrar, address omegaCurrentRefrrar, address sigmaCurrentreferrar) public onlyOwner {
        users[userAddress] = User({
            id : _userId,
            referrer: _referrerAddress,
            partnersCount: _partnersCount
        });
        for(uint8 i = 1; i <= 15; i++) {
            if(i <= alphaPkg) {
                users[userAddress].alphaLearningPackage[i] = true;
                users[userAddress].alphaMatrix[i].currentReferrer = alphaCurrentReferrar;
            }
            if(i <= sigmaPkg) {
                users[userAddress].sigmaLearningPackage[i] = true;
                users[userAddress].sigmaMatrix[i].currentReferrer = sigmaCurrentreferrar;
            }
            if(i <= 8 && i <= omegaPkg) {
                users[userAddress].omegaLearningPackage[i] = true;
                users[userAddress].omegaMatrix[i].currentReferrer = omegaCurrentRefrrar;
            }
        }
    }
    function updateAlphaStatic(address userAddress, address[] memory _referrals,uint8 packageNum) public onlyOwner {
        users[userAddress].alphaMatrix[packageNum].referrals = _referrals;
    }
    function updateSigmaStatic(address userAddress, address[] memory firstLevel, address[] memory secondLevel, address[] memory thirdLevel,uint8 packageNum) public onlyOwner {
        if(firstLevel.length != 0) users[userAddress].sigmaMatrix[packageNum].firstLevelReferrals = firstLevel;
        if(secondLevel.length != 0) users[userAddress].sigmaMatrix[packageNum].secondLevelReferrals = secondLevel;
        if(thirdLevel.length != 0) users[userAddress].sigmaMatrix[packageNum].thirdLevelReferrals = thirdLevel;
    }
    function updateOmegaStatic(address userAddress, address [] memory firstLevel, address[] memory secondLevel, uint8 packageNum) public onlyOwner {
        if(firstLevel.length != 0) users[userAddress].sigmaMatrix[packageNum].firstLevelReferrals = firstLevel;
        if(secondLevel.length != 0) users[userAddress].sigmaMatrix[packageNum].secondLevelReferrals = secondLevel;
    }
}
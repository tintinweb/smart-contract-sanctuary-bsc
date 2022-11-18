/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

pragma solidity >=0.5.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

interface IBUSDcoin {

    function balanceOf(address _owner) view external  returns (uint256 balance);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) view external  returns (uint256 remaining);

}

contract Quantum_Cube {
    using SafeMath for uint256;
    IBUSDcoin token;
    uint256 internal constant ENTRY_AMOUNT = 1;
    uint256[] internal basketPrice;
    uint256 internal totalUsers;
    uint256 internal extraWallet;
    address owner;
    
    struct User {
        uint256 id;
        uint256[] referralArray;
        address upline;
        uint256 basketsPurchased;
        uint256 totalEarning;
        uint256 balanceEarnedBonus;
        bool isExist;
    }

    struct UserCycles{
        uint256 cycle1;
        uint256 cycle2;
        uint256 cycle3;
        uint256 cycle4;
        uint256 cycle5;
        uint256 cycle6;
        uint256 cycle7;
        uint256 cycle8;
        uint256 cycle9;
        uint256 cycle10;
        uint256 cycle11;
        uint256 cycle12;
        uint256 cycle13;
        uint256 cycle14;
    }

    struct DataLevel {
        uint256 level;
        address[] partners;
        uint256 reinvesments;
    }
    
    mapping(address => mapping(uint256 => DataLevel)) public dataLevels;
    mapping(address => User) public users;
    mapping(uint256 => address) internal usersId;
    mapping(address => UserCycles) public cycles;
    
    event RegisterEvent(address _add);
    event DistributeAmountEvent(address _upline, uint256 _percent, uint256 _amount);
    event BuyBasketEvent(address _user,uint256 _basketNumber);
    event ExtraWalletTransferEvent(uint256 _percent,uint256 _amount);
 
    constructor(address _owner) public payable {
        owner = _owner;
        require(msg.value >= ENTRY_AMOUNT, "insufficient amount");
        extraWallet = extraWallet.add(1);
        address(uint256(owner)).transfer(1);
        totalUsers = 1;
        users[msg.sender].id = totalUsers;
        users[msg.sender].isExist = true;
        users[msg.sender].upline = address(0);
        users[msg.sender].basketsPurchased = 1;
        
        usersId[totalUsers] = msg.sender;
        
        basketPrice.push(1);
        basketPrice.push(2);
        basketPrice.push(4);
        basketPrice.push(8);
        basketPrice.push(16);
        basketPrice.push(32);
        basketPrice.push(64);
        basketPrice.push(128);
        basketPrice.push(256);
        basketPrice.push(512);
        basketPrice.push(1024);
        basketPrice.push(2048);
        basketPrice.push(4096);
        basketPrice.push(8192);

        setInitialDataForLevels(msg.sender);

        token = IBUSDcoin(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    //function to register user
    function Register(address _upline) public payable {
        require(msg.value >= ENTRY_AMOUNT, "less amount");
        require(users[msg.sender].isExist == false, "user already exist");
        require(users[_upline].isExist == true, "upline not exist");

        totalUsers++;
        users[msg.sender].id = totalUsers;
        users[msg.sender].upline = _upline;
        users[msg.sender].isExist = true;
        users[msg.sender].basketsPurchased=1;
        usersId[totalUsers] = msg.sender;
        users[_upline].referralArray.push(totalUsers);
        setDataLevel(msg.sender, 1);
        cycles[_upline].cycle1++;

        if(cycles[_upline].cycle1%4==0)
        amountDistribute(1, true, true);
        else
        amountDistribute(1, false, true);
      
        emit RegisterEvent(msg.sender);
    }

    //function to distribute basket amount ie 50% 25% 15% 10% if its not 4th user of that cycle
    function amountDistribute(uint256 _level, bool _is4thUser, bool isRegister) internal {
        uint256 valueBasketLocal = basketPrice[_level-1];
        bool flag;

        if (_is4thUser) {
            address ref=users[users[msg.sender].upline].upline;
            while (ref!=address(0)) {
                if (checkEligibility(ref,_level) ) {
                    if (isRegister) {
                        users[ref].totalEarning=users[ref].totalEarning.add(valueBasketLocal);
                        address(uint256(ref)).transfer(valueBasketLocal);
                        users[ref].balanceEarnedBonus = users[ref].balanceEarnedBonus.add(valueBasketLocal);
                    } else {
                        users[ref].totalEarning=users[ref].totalEarning.add(valueBasketLocal - 1);
                        address(uint256(ref)).transfer(valueBasketLocal - 1);
                        address(uint256(owner)).transfer(1);
                        users[ref].balanceEarnedBonus = users[ref].balanceEarnedBonus.add(valueBasketLocal - 1);
                    }
                    flag = true;
                    break;
                }

                ref=users[ref].upline;
            }
            if (flag==false) {
                if (isRegister) {
                    address(uint256(owner)).transfer(valueBasketLocal);
                } else {
                    address(uint256(owner)).transfer(valueBasketLocal - 1);
                    address(uint256(owner)).transfer(1);
                }
            }
        } else {
            uint256 total = 100;
            uint256 currAmount = 50;
            address ref = users[msg.sender].upline;

            while (currAmount!=0 && ref!=address(0)) {
                if (users[ref].basketsPurchased>=_level && currAmount==50) {
                    redistributeBalanceRefactor(isRegister, _level, currAmount, ref);

                    currAmount = 25;
                    total = total.sub(50);
                }
                else if(users[ref].basketsPurchased>=_level && currAmount==25){
                    redistributeBalanceRefactor(isRegister, _level, currAmount, ref);

                    currAmount = 15;
                    total = total.sub(25);
                }
                else if(users[ref].basketsPurchased>=_level && currAmount==15){
                    redistributeBalanceRefactor(isRegister, _level, currAmount, ref);

                    currAmount = 10;
                    total = total.sub(15);
                }
                else if(users[ref].basketsPurchased>=_level && currAmount==10){
                    redistributeBalanceRefactor(isRegister, _level, currAmount, ref);

                    currAmount = 0;
                    total = total.sub(10);
                }

                ref = users[ref].upline;
            }
            
            if (isRegister) {
                extraWallet = extraWallet.add(valueBasketLocal.mul(total).div(100));
                address(uint256(owner)).transfer(valueBasketLocal.mul(total).div(100));
                emit ExtraWalletTransferEvent(total,valueBasketLocal.mul(total).div(100));
            } else {
                extraWallet = extraWallet.add((valueBasketLocal - 1).mul(total).div(100));
                address(uint256(owner)).transfer((valueBasketLocal - 1).mul(total).div(100));
                address(uint256(owner)).transfer(1);
                emit ExtraWalletTransferEvent(total,(valueBasketLocal - 1).mul(total).div(100));
            }
        }
    }

    // Function to refactor distribute balance
    function redistributeBalanceRefactor(bool isRegister, uint256 _level, uint256 currAmount, address ref) private {
        uint256 valueBasketLocal = basketPrice[_level-1];
        
        if (isRegister) {
            users[ref].totalEarning= users[ref].totalEarning.add(valueBasketLocal.mul(currAmount).div(100));
            address(uint256(ref)).transfer(valueBasketLocal.mul(currAmount).div(100));
            emit DistributeAmountEvent(ref,currAmount,valueBasketLocal.mul(currAmount).div(100));
        } else {
            users[ref].totalEarning= users[ref].totalEarning.add((valueBasketLocal - 1).mul(currAmount).div(100));
            address(uint256(ref)).transfer((valueBasketLocal - 1).mul(currAmount).div(100));
            uint256 localVar = (valueBasketLocal - 1).mul(currAmount).div(100);
            emit DistributeAmountEvent(ref,currAmount,localVar);
        }
    }
    
    // function to buy a basket
    function buyBasket(uint256 _basketNumber) public payable {
        require(
            _basketNumber > users[msg.sender].basketsPurchased && _basketNumber <= 14,
            "basket already purchased"
        );
        require(
            _basketNumber == users[msg.sender].basketsPurchased + 1,
            "you need to purchase previous basket first"
        );
        require(
            msg.value >= basketPrice[_basketNumber - 1],
            "you should have enough balance"
        );
        
        users[msg.sender].basketsPurchased = users[msg.sender].basketsPurchased.add(1);
        emit BuyBasketEvent(msg.sender,_basketNumber);
            
        if(_basketNumber == 2){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle2 ++;
            if(cycles[users[msg.sender].upline].cycle2%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 3){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle3 ++;
            if(cycles[users[msg.sender].upline].cycle3%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 4){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle4 ++;
            if(cycles[users[msg.sender].upline].cycle4%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 5){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle5 ++;
            if(cycles[users[msg.sender].upline].cycle5%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 6){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle6 ++;
            if(cycles[users[msg.sender].upline].cycle6%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 7){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle7 ++;
            if(cycles[users[msg.sender].upline].cycle7%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 8){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle8 ++;
            if(cycles[users[msg.sender].upline].cycle8%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 9){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle9 ++;
            if(cycles[users[msg.sender].upline].cycle9%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 10){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle10 ++;
            if(cycles[users[msg.sender].upline].cycle10%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 11){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle11 ++;
            if(cycles[users[msg.sender].upline].cycle11%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 12){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle12 ++;
            if(cycles[users[msg.sender].upline].cycle12%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 13){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle13 ++;
            if(cycles[users[msg.sender].upline].cycle13%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
        else  if(_basketNumber == 14){
            setDataLevel(msg.sender, _basketNumber);
            cycles[users[msg.sender].upline].cycle14 ++;
            if(cycles[users[msg.sender].upline].cycle14%4==0){
                amountDistribute(_basketNumber,true, false);
            }
            else
            amountDistribute(_basketNumber,false, false);
        }
            
    }

    function checkEligibility(address _user,uint256 _basketNumber) internal view returns(bool){
        if(cycles[_user].cycle1%4 >= 1){
            if(users[_user].basketsPurchased>1 && users[_user].basketsPurchased>= _basketNumber){
                return true;
            }
            else
            return false;
        }
        else{
            if(users[_user].basketsPurchased>= _basketNumber){
                return true;
            }
            else
            return false;
        }
    }

    //   external getter functions
    function getUserInfo(address _addr) external view returns(
        uint256 id,
        address upline,
        uint256 basketsPurchased,
        uint256 totalEarning,
        bool isExist
    ) {
        User memory user=users[_addr];
        return (user.id,user.upline,user.basketsPurchased,user.totalEarning,user.isExist);
    }
    
    function getTotalUsers() public view returns(uint256){
        return totalUsers;
    }
    
    function getUserAddressUsingId(uint256 _id) public view returns(address){
        return usersId[_id];
    }

    function setInitialDataForLevels(address myAddress) private {
        uint256 quantityLevels = 14;

        for (uint256 i; i <= quantityLevels; i++) {
            dataLevels[myAddress][i].level = i;
            dataLevels[myAddress][i].reinvesments = 0;
        }
    }

    function getDataLevelCubo(address myAddress, uint256 levelCubo) public view returns(uint256 level, bool purchased, address[] memory partners, uint256 reinvesmentsLineOne) {
        bool isPurchased = false;
        User memory user = users[myAddress];
        if (levelCubo <= user.basketsPurchased) {
            isPurchased = true;
        } else {
            isPurchased = false;
        }
        
        DataLevel memory dataLevel = dataLevels[myAddress][levelCubo];
        
        return (
            dataLevel.level,
            isPurchased,
            dataLevel.partners,
            dataLevel.reinvesments
        );
    }
    
    function getDataLevelInOneLine(address myAddress, uint256 levelCubo) public view returns(uint256 quantityPartners, uint256 reinvesments) {
        DataLevel memory dataLevel = dataLevels[myAddress][levelCubo];
        
        return (
            dataLevel.partners.length,
            dataLevel.reinvesments
        );
    }
    
    function getDataLevelInTwoLine(address myAddress, uint256 levelCubo) public view returns(uint256 quantityPartners, uint256 reinvesments) {
        DataLevel memory dataLevel = dataLevels[myAddress][levelCubo];

        uint256 lengthPartners = dataLevel.partners.length;
        
        uint256 _quantityPartners = 0;
        uint256 _reinvesments = 0;

        if (lengthPartners > 0) {
            for (uint256 i = 0; i < lengthPartners; i++) {
                address addressPartner = dataLevel.partners[i];
                
                DataLevel memory lineTwoDataLevel = dataLevels[addressPartner][levelCubo];
                _quantityPartners += lineTwoDataLevel.partners.length;
                _reinvesments += lineTwoDataLevel.reinvesments;
            }
        }
        
        return (
            _quantityPartners,
            _reinvesments
        );
    }
    
    function getDataLevelInThreeLine(address myAddress, uint256 levelCubo) public view returns(uint256 quantityPartners, uint256 reinvesments) {
        DataLevel memory dataLevel = dataLevels[myAddress][levelCubo];

        uint256 lengthPartnersLineOne = dataLevel.partners.length;
        
        uint256 _quantityPartners = 0;
        uint256 _reinvesments = 0;

        if (lengthPartnersLineOne > 0) {
            for (uint256 i = 0; i < lengthPartnersLineOne; i++) {
                address addressPartnerLineOne = dataLevel.partners[i];
                DataLevel memory lineTwoDataLevel = dataLevels[addressPartnerLineOne][levelCubo];
                uint256 lengthPartnersLineTwo = lineTwoDataLevel.partners.length;
                
                if (lengthPartnersLineTwo > 0) {
                    for (uint256 j; j < lengthPartnersLineTwo; j++) {
                        address addressPartnerLineTwo = lineTwoDataLevel.partners[j];
                        DataLevel memory lineThreeDataLevel = dataLevels[addressPartnerLineTwo][levelCubo];
                        _quantityPartners += lineThreeDataLevel.partners.length;
                        _reinvesments += lineThreeDataLevel.reinvesments;
                    }
                }
            }
        }
        
        return (
            _quantityPartners,
            _reinvesments
        );
    }
    
    function getDataLevelInFourLine(address myAddress, uint256 levelCubo) public view returns(uint256 quantityPartners, uint256 reinvesments) {
        DataLevel memory dataLevel = dataLevels[myAddress][levelCubo];
        uint256 lengthPartnersLineOne = dataLevel.partners.length;
        uint256 _quantityPartners = 0;
        uint256 _reinvesments = 0;

        if (lengthPartnersLineOne > 0) {
            for (uint256 i = 0; i < lengthPartnersLineOne; i++) {
                address addressPartnerLineOne = dataLevel.partners[i];
                DataLevel memory lineTwoDataLevel = dataLevels[addressPartnerLineOne][levelCubo];
                uint256 lengthPartnersLineTwo = lineTwoDataLevel.partners.length;
                
                if (lengthPartnersLineTwo > 0) {
                    for (uint256 j; j < lengthPartnersLineTwo; j++) {
                        address addressPartnerLineTwo = lineTwoDataLevel.partners[j];
                        DataLevel memory lineThreeDataLevel = dataLevels[addressPartnerLineTwo][levelCubo];
                        uint256 lengthPartnersLineThree = lineThreeDataLevel.partners.length;
                        
                        if (lengthPartnersLineThree > 0) {
                            uint256 levelCuboForFour = levelCubo;
                            
                            for (uint256 k; k < lengthPartnersLineThree; k++) {
                                address addressPartnerLineThree = lineThreeDataLevel.partners[k];
                                DataLevel memory lineFourDataLevel = dataLevels[addressPartnerLineThree][levelCuboForFour];
                                _quantityPartners += lineFourDataLevel.partners.length;
                                _reinvesments += lineFourDataLevel.reinvesments;
                            }
                        }
                    }
                }
            }
        }
        
        return (
            _quantityPartners,
            _reinvesments
        );
    }

    function setDataLevel(address myAddress, uint256 levelCubo) private {
        address mySponsor = users[myAddress].upline;

        if (mySponsor != address(0)) {
            dataLevels[mySponsor][levelCubo].partners.push(myAddress);
            if (isDivisibleByFour((dataLevels[mySponsor][levelCubo].partners).length) == 0) {
                dataLevels[mySponsor][levelCubo].reinvesments ++;
            }
        } else {
            dataLevels[owner][levelCubo].partners.push(myAddress);
            if (isDivisibleByFour((dataLevels[owner][levelCubo].partners).length) == 0) {
                dataLevels[owner][levelCubo].reinvesments ++;
            }
        }
    }

    function isDivisibleByFour(uint256 quantityPartners) private pure returns(uint256 modResult) {
        uint256 modValue = 4;
        return quantityPartners % modValue;
    }

    function getDataPricesByBaskets() public view returns(uint256[] memory) {
        return basketPrice;
    }
}
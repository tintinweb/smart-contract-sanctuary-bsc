// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MetaBotz is IERC20 {
    using SafeMath for uint256;

    uint256 private _totalSupply = uint256(250000000 * 1 ether);

    string public constant name = "Metabotz";
    string public constant symbol = "MTBZ";
    uint8 public constant decimals = 18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address payable public _admin;

    address public _privateSaleContract;
    uint256 public _privateSaleAmountCap = uint256(12500000 * 1 ether);

    address public _presaleContract;
    uint256 public _presaleAmountCap = uint256(50000000 * 1 ether);

    address public _swapContract;
    uint256 public _swapAmountCap = uint256(3000000 * 1 ether);

    bool public _isPaused;
    mapping(address => bool) public _isPausedAddress;

    string[] public _groups;
    uint256[] public _dates;
    mapping(string => uint256) public _groupsAmountCap;
    mapping(string => address) public _groupsAddress;
    mapping(string => mapping(uint256 => uint256)) public _tokenAllocation;
    mapping(string => mapping(uint256 => mapping(uint256 => bool))) public _tokenAllocationStatus;

    event OutOfMoney(string group);

    //Wallet Addresses
    address public _deadAddress = 0x000000000000000000000000000000000000dEaD;

    address private _Liquidity = 0x44f7a0CfDB078CDA00E067933c4ca6CebE5D73c0;
    address private _Development = 0x7BFd0A2d6fba87Fb6254a35a1C13Eee6a30bDaaC;
    address private _Marketing = 0x00e4c14A285bf2b1Ac78eAE6d730ae2d6d56544d;
    address private _PlayToEarn = 0xe605Deb1aA42bc9A7883d65d0e068C48eB9cCfEe;
    address private _DevsTeam = 0x5c06a87768C3E88464eFA37544A5bFF9C08BE7FF;
    address private _Advisor = 0xbabBF04370D8Fb47C0f1b59FE98A2f63D4d27035;
    address private _Staking = 0xC0DfC016629ec91BD79253e103c169aa5Ab6C7C6;

    //Vesting Dates
	//Monthly
    uint256 public constant May_01_2022 = 1651363200;
    uint256 public constant June_01_2022 = 1654041600;
    uint256 public constant July_01_2022 = 1656633600;
    uint256 public constant August_01_2022 = 1659312000;
    uint256 public constant September_01_2022 = 1661990400;
    uint256 public constant October_01_2022 = 1664582400;
    uint256 public constant November_01_2022 = 1667260800;
    uint256 public constant December_01_2022 = 1669852800;

    uint256 public constant January_01_2023 = 1672531200;
    uint256 public constant February_01_2023 = 1675209600;
    uint256 public constant March_01_2023 = 1677628800;
    uint256 public constant April_01_2023 = 1680307200;
    uint256 public constant May_01_2023 = 1682899200;
    uint256 public constant June_01_2023 = 1685577600;
    uint256 public constant July_01_2023 = 1688169600;
    uint256 public constant August_01_2023 = 1690848000;
    uint256 public constant September_01_2023 = 1693526400;
    uint256 public constant October_01_2023 = 1696118400;
    uint256 public constant November_01_2023 = 1698796800;
    uint256 public constant December_01_2023 = 1701388800;

    uint256 public constant January_01_2024 = 1704067200;
    uint256 public constant February_01_2024 = 1706745600;
    uint256 public constant March_01_2024 = 1709251200;
    uint256 public constant April_01_2024 = 1711929600;
    uint256 public constant May_01_2024 = 1714521600;
    uint256 public constant June_01_2024 = 1717200000;
    uint256 public constant July_01_2024 = 1719792000;
    uint256 public constant August_01_2024 = 1722470400;
    uint256 public constant September_01_2024 = 1725148800;
    uint256 public constant October_01_2024 = 1727740800;
    uint256 public constant November_01_2024 = 1730419200;
    uint256 public constant December_01_2024 = 1733011200;

    uint256 public constant January_01_2025 = 1735689600;
    uint256 public constant February_01_2025 = 1738368000;
    uint256 public constant March_01_2025 = 1740787200;
    uint256 public constant April_01_2025 = 1743465600;
    uint256 public constant May_01_2025 = 1746057600;
    uint256 public constant June_01_2025 = 1748736000;
    uint256 public constant July_01_2025 = 1751328000;
    uint256 public constant August_01_2025 = 1754006400;
    uint256 public constant September_01_2025 = 1756684800;
    uint256 public constant October_01_2025 = 1759276800;
    uint256 public constant November_01_2025 = 1761955200;
    uint256 public constant December_01_2025 = 1764547200;

    // Weekly Vesting
    uint256 public constant April_17_2022 = 1650153600;
    uint256 public constant April_24_2022 = 1650758400;

    uint256 public constant May_08_2022 = 1651968000;
    uint256 public constant May_15_2022 = 1652572800;
    uint256 public constant May_22_2022 = 1653177600;
    uint256 public constant May_29_2022 = 1653782400;

    uint256 public constant June_05_2022 = 1654387200;
    uint256 public constant June_12_2022 = 1654992000;
    uint256 public constant June_19_2022 = 1655596800;
    uint256 public constant June_26_2022 = 1656201600;

    uint256 public constant July_03_2022 = 1656806400;
    uint256 public constant July_10_2022 = 1657411200;
    uint256 public constant July_17_2022 = 1658016000;
    uint256 public constant July_24_2022 = 1658620800;
    uint256 public constant July_31_2022 = 1659225600;

    uint256 public constant August_07_2022 = 1659830400;
    uint256 public constant August_14_2022 = 1660435200;
    uint256 public constant August_21_2022 = 1661040000;
    uint256 public constant August_28_2022 = 1661644800;

    uint256 public constant September_04_2022 = 1662249600;
    uint256 public constant September_11_2022 = 1662854400;
    uint256 public constant September_18_2022 = 1663459200;
    uint256 public constant September_25_2022 = 1664064000;

    uint256 public constant October_02_2022 = 1664668800;
    uint256 public constant October_09_2022 = 1665273600;
    uint256 public constant October_16_2022 = 1665878400;
    uint256 public constant October_23_2022 = 1666483200;
    uint256 public constant October_30_2022 = 1667088000;

    uint256 public constant November_06_2022 = 1667692800;
    uint256 public constant November_13_2022 = 1668297600;
    uint256 public constant November_20_2022 = 1668902400;
    uint256 public constant November_27_2022 = 1669507200;

    uint256 public constant December_04_2022 = 1670112000;
    uint256 public constant December_11_2022 = 1670716800;
    uint256 public constant December_18_2022 = 1671321600;
    uint256 public constant December_25_2022 = 1671926400;

    uint256 public constant January_08_2023 = 1673136000;
    uint256 public constant January_15_2023 = 1673740800;
    uint256 public constant January_22_2023 = 1674345600;
    uint256 public constant January_29_2023 = 1674950400;

    uint256 public constant February_05_2023 = 1675555200;

    uint256 public constant February_12_2023 = 1676160000;
    uint256 public constant February_19_2023 = 1676764800;
    uint256 public constant February_26_2023 = 1677369600;
    uint256 public constant March_05_2023 = 1677974400;
    uint256 public constant March_12_2023 = 1678579200;
    
    constructor() {
        _admin = payable(msg.sender);
        _balances[address(this)] = _totalSupply;

        _groupsAddress["Liquidity"] = _Liquidity;
        _groupsAddress["Development"] = _Development;
        _groupsAddress["Marketing"] = _Marketing;
        _groupsAddress["PlayToEarn"] = _PlayToEarn;
        _groupsAddress["DevsTeam"] = _DevsTeam;
        _groupsAddress["Advisor"] = _Advisor;
        _groupsAddress["Staking"] = _Staking;

        setValues();
        setTokenVesting();
        initialTransfer();
    }

    function setValues() private {


        _groups.push("Development");
        _groups.push("Marketing");
        _groups.push("PlayToEarn");		
        _groups.push("DevsTeam");
        _groups.push("Advisor");				
        _groups.push("Staking");


        _groupsAmountCap["Development"] = uint256(18000000 * 1 ether);
        _groupsAmountCap["Marketing"] = uint256(9500000 * 1 ether);
        _groupsAmountCap["Staking"] = uint256(10000000 * 1 ether);
        _groupsAmountCap["PlayToEarn"] = uint256(92000000 * 1 ether);
        _groupsAmountCap["DevsTeam"] = uint256(11250000 * 1 ether);
        _groupsAmountCap["Advisor"] = uint256(11250000 * 1 ether);

        _dates.push(May_01_2022);
        _dates.push(June_01_2022);
        _dates.push(July_01_2022);
        _dates.push(August_01_2022);
        _dates.push(September_01_2022);
        _dates.push(October_01_2022);
        _dates.push(November_01_2022);
        _dates.push(December_01_2022);

        _dates.push(January_01_2023);
        _dates.push(February_01_2023);
        _dates.push(March_01_2023);
        _dates.push(April_01_2023);
        _dates.push(May_01_2023);
        _dates.push(June_01_2023);
        _dates.push(July_01_2023);
        _dates.push(August_01_2023);
        _dates.push(September_01_2023);
        _dates.push(October_01_2023);
        _dates.push(November_01_2023);
        _dates.push(December_01_2023);

        _dates.push(January_01_2024);
        _dates.push(February_01_2024);
        _dates.push(March_01_2024);
        _dates.push(April_01_2024);
        _dates.push(May_01_2024);
        _dates.push(June_01_2024);
        _dates.push(July_01_2024);
        _dates.push(August_01_2024);
        _dates.push(September_01_2024);
        _dates.push(October_01_2024);
        _dates.push(November_01_2024);
        _dates.push(December_01_2024);

        _dates.push(January_01_2025);
        _dates.push(February_01_2025);
        _dates.push(March_01_2025);
        _dates.push(April_01_2025);
        _dates.push(May_01_2025);
        _dates.push(June_01_2025);
        _dates.push(July_01_2025);
        _dates.push(August_01_2025);
        _dates.push(September_01_2025);
        _dates.push(October_01_2025);
        _dates.push(November_01_2025);
        _dates.push(December_01_2025);

        //Weekly
        _dates.push(April_17_2022);
        _dates.push(April_24_2022);

        _dates.push(May_08_2022);
        _dates.push(May_15_2022);
        _dates.push(May_22_2022);
        _dates.push(May_29_2022);

        _dates.push(June_05_2022);
        _dates.push(June_12_2022);
        _dates.push(June_19_2022);
        _dates.push(June_26_2022);

        _dates.push(July_03_2022);
        _dates.push(July_10_2022);
        _dates.push(July_17_2022);
        _dates.push(July_24_2022);
        _dates.push(July_31_2022);

        _dates.push(August_07_2022);
        _dates.push(August_14_2022);
        _dates.push(August_21_2022);
        _dates.push(August_28_2022);

        _dates.push(September_04_2022);
        _dates.push(September_11_2022);
        _dates.push(September_18_2022);
        _dates.push(September_25_2022);

        _dates.push(October_02_2022);
        _dates.push(October_09_2022);
        _dates.push(October_16_2022);
        _dates.push(October_23_2022);
        _dates.push(October_30_2022);

        _dates.push(November_06_2022);
        _dates.push(November_13_2022);
        _dates.push(November_20_2022);
        _dates.push(November_27_2022);

        _dates.push(December_04_2022);
        _dates.push(December_11_2022);
        _dates.push(December_18_2022);
        _dates.push(December_25_2022);

        _dates.push(January_08_2023);
        _dates.push(January_15_2023);
        _dates.push(January_22_2023);
        _dates.push(January_29_2023);

        _dates.push(February_05_2023);
        _dates.push(February_12_2023);
        _dates.push(February_19_2023);
        _dates.push(February_26_2023);

        _dates.push(March_05_2023);
        _dates.push(March_12_2023);
    }

    function setTokenVesting() private {


        //Marketing, Weekly Vesting = 42 Weeks 
        _tokenAllocation["Marketing"][May_29_2022] = uint256(226190 * 1 ether); // Week 1
        _tokenAllocation["Marketing"][June_05_2022] = uint256(226190 * 1 ether); // Week 2
        _tokenAllocation["Marketing"][June_12_2022] = uint256(226190 * 1 ether); // Week 3
        _tokenAllocation["Marketing"][June_19_2022] = uint256(226190 * 1 ether); // Week 4
        _tokenAllocation["Marketing"][June_26_2022] = uint256(226190 * 1 ether); // Week 5
        _tokenAllocation["Marketing"][July_03_2022] = uint256(226190 * 1 ether); // Week 6
        _tokenAllocation["Marketing"][July_10_2022] = uint256(226190 * 1 ether); // Week 7
        _tokenAllocation["Marketing"][July_17_2022] = uint256(226190 * 1 ether); // Week 8
        _tokenAllocation["Marketing"][July_24_2022] = uint256(226190 * 1 ether); // Week 9
        _tokenAllocation["Marketing"][July_31_2022] = uint256(226190 * 1 ether); // Week 10
        _tokenAllocation["Marketing"][August_07_2022] = uint256(226190 * 1 ether); // Week 11
        _tokenAllocation["Marketing"][August_14_2022] = uint256(226190 * 1 ether); // Week 12
        _tokenAllocation["Marketing"][August_21_2022] = uint256(226190 * 1 ether); // Week 13
        _tokenAllocation["Marketing"][August_28_2022] = uint256(226190 * 1 ether); // Week 14
        _tokenAllocation["Marketing"][September_04_2022] = uint256(226190 * 1 ether); // Week 15
        _tokenAllocation["Marketing"][September_11_2022] = uint256(226190 * 1 ether); // Week 16
        _tokenAllocation["Marketing"][September_18_2022] = uint256(226190 * 1 ether); // Week 17
        _tokenAllocation["Marketing"][September_25_2022] = uint256(226190 * 1 ether); // Week 18
        _tokenAllocation["Marketing"][October_02_2022] = uint256(226190 * 1 ether); // Week 19
        _tokenAllocation["Marketing"][October_09_2022] = uint256(226190 * 1 ether); // Week 20
        _tokenAllocation["Marketing"][October_16_2022] = uint256(226190 * 1 ether); // Week 21
        _tokenAllocation["Marketing"][October_23_2022] = uint256(226190 * 1 ether); // Week 22
        _tokenAllocation["Marketing"][October_30_2022] = uint256(226190 * 1 ether); // Week 23
        _tokenAllocation["Marketing"][November_06_2022] = uint256(226190 * 1 ether); // Week 24
        _tokenAllocation["Marketing"][November_13_2022] = uint256(226190 * 1 ether); // Week 25
        _tokenAllocation["Marketing"][November_20_2022] = uint256(226190 * 1 ether); // Week 26
        _tokenAllocation["Marketing"][November_27_2022] = uint256(226190 * 1 ether); // Week 27
        _tokenAllocation["Marketing"][December_04_2022] = uint256(226190 * 1 ether); // Week 28
        _tokenAllocation["Marketing"][December_11_2022] = uint256(226190 * 1 ether); // Week 29
        _tokenAllocation["Marketing"][December_18_2022] = uint256(226190 * 1 ether); // Week 30
        _tokenAllocation["Marketing"][December_25_2022] = uint256(226190 * 1 ether); // Week 31
        _tokenAllocation["Marketing"][January_01_2023] = uint256(226190 * 1 ether); // Week 32
        _tokenAllocation["Marketing"][January_08_2023] = uint256(226190 * 1 ether); // Week 33
        _tokenAllocation["Marketing"][January_15_2023] = uint256(226190 * 1 ether); // Week 34
        _tokenAllocation["Marketing"][January_22_2023] = uint256(226190 * 1 ether); // Week 35
        _tokenAllocation["Marketing"][January_29_2023] = uint256(226190 * 1 ether); // Week 36
        _tokenAllocation["Marketing"][February_05_2023] = uint256(226190 * 1 ether); // Week 37
        _tokenAllocation["Marketing"][February_12_2023] = uint256(226190 * 1 ether); // Week 38
        _tokenAllocation["Marketing"][February_19_2023] = uint256(226190 * 1 ether); // Week 39
        _tokenAllocation["Marketing"][February_26_2023] = uint256(226190 * 1 ether); // Week 40
        _tokenAllocation["Marketing"][March_05_2023] = uint256(226190 * 1 ether); // Week 41
        _tokenAllocation["Marketing"][March_12_2023] = uint256(226190 * 1 ether); // Week 42

        //Development, Monthly Vesting = 12 Months
        _tokenAllocation["Development"][July_01_2022] = uint256(1500000 * 1 ether); // Month 1
        _tokenAllocation["Development"][August_01_2022] = uint256(1500000 * 1 ether); // Month 2
        _tokenAllocation["Development"][September_01_2022] = uint256(1500000 * 1 ether); // Month 3
        _tokenAllocation["Development"][October_01_2022] = uint256(1500000 * 1 ether); // Month 4
        _tokenAllocation["Development"][November_01_2022] = uint256(1500000 * 1 ether); // Month 5
        _tokenAllocation["Development"][December_01_2022] = uint256(1500000 * 1 ether); // Month 6
        _tokenAllocation["Development"][January_01_2023] = uint256(1500000 * 1 ether); // Month 7
        _tokenAllocation["Development"][February_01_2023] = uint256(1500000 * 1 ether); // Month 8
        _tokenAllocation["Development"][March_01_2023] = uint256(1500000 * 1 ether); // Month 9
        _tokenAllocation["Development"][April_01_2023] = uint256(1500000 * 1 ether); // Month 10
        _tokenAllocation["Development"][May_01_2023] = uint256(1500000 * 1 ether); // Month 11
        _tokenAllocation["Development"][June_01_2023] = uint256(1500000 * 1 ether); // Month 12

        //DevsTeam, Monthly Vesting = 36 Months
        _tokenAllocation["DevsTeam"][July_01_2022] = uint256(312500 * 1 ether); // Month 1
        _tokenAllocation["DevsTeam"][August_01_2022] = uint256(312500 * 1 ether);  // Month 2
        _tokenAllocation["DevsTeam"][September_01_2022] = uint256(312500 * 1 ether); // Month 3
        _tokenAllocation["DevsTeam"][October_01_2022] = uint256(312500 * 1 ether); // Month 4
        _tokenAllocation["DevsTeam"][November_01_2022] = uint256(312500 * 1 ether); // Month 5
        _tokenAllocation["DevsTeam"][December_01_2022] = uint256(312500 * 1 ether); // Month 6 
        _tokenAllocation["DevsTeam"][January_01_2023] = uint256(312500 * 1 ether); // Month 7
        _tokenAllocation["DevsTeam"][February_01_2023] = uint256(312500 * 1 ether); // Month 8
        _tokenAllocation["DevsTeam"][March_01_2023] = uint256(312500 * 1 ether); // Month 9
        _tokenAllocation["DevsTeam"][April_01_2023] = uint256(312500 * 1 ether); // Month 10
        _tokenAllocation["DevsTeam"][May_01_2023] = uint256(312500 * 1 ether); // Month 11
        _tokenAllocation["DevsTeam"][June_01_2023] = uint256(312500 * 1 ether); // Month 12
        _tokenAllocation["DevsTeam"][July_01_2023] = uint256(312500 * 1 ether); // Month 13
        _tokenAllocation["DevsTeam"][August_01_2023] = uint256(312500 * 1 ether); // Month 14
        _tokenAllocation["DevsTeam"][September_01_2023] = uint256(312500 * 1 ether); // Month 15
        _tokenAllocation["DevsTeam"][October_01_2023] = uint256(312500 * 1 ether); // Month 16
        _tokenAllocation["DevsTeam"][November_01_2023] = uint256(312500 * 1 ether); // Month 17
        _tokenAllocation["DevsTeam"][December_01_2023] = uint256(312500 * 1 ether); // Month 18
        _tokenAllocation["DevsTeam"][January_01_2024] = uint256(312500 * 1 ether); // Month 19
        _tokenAllocation["DevsTeam"][February_01_2024] = uint256(312500 * 1 ether); // Month 20
        _tokenAllocation["DevsTeam"][March_01_2024] = uint256(312500 * 1 ether); // Month 21
        _tokenAllocation["DevsTeam"][April_01_2024] = uint256(312500 * 1 ether); // Month 22
        _tokenAllocation["DevsTeam"][May_01_2024] = uint256(312500 * 1 ether); // Month 23
        _tokenAllocation["DevsTeam"][June_01_2024] = uint256(312500 * 1 ether); // Month 24
        _tokenAllocation["DevsTeam"][July_01_2024] = uint256(312500 * 1 ether); // Month 25
        _tokenAllocation["DevsTeam"][August_01_2024] = uint256(312500 * 1 ether); // Month 26
        _tokenAllocation["DevsTeam"][September_01_2024] = uint256(312500 * 1 ether); // Month 27
        _tokenAllocation["DevsTeam"][October_01_2024] = uint256(312500 * 1 ether); // Month 28
        _tokenAllocation["DevsTeam"][November_01_2024] = uint256(312500 * 1 ether); // Month 29
        _tokenAllocation["DevsTeam"][December_01_2024] = uint256(312500 * 1 ether); // Month 30
        _tokenAllocation["DevsTeam"][January_01_2025] = uint256(312500 * 1 ether); // Month 31
        _tokenAllocation["DevsTeam"][February_01_2025] = uint256(312500 * 1 ether); // Month 32
        _tokenAllocation["DevsTeam"][March_01_2025] = uint256(312500 * 1 ether); // Month 33
        _tokenAllocation["DevsTeam"][April_01_2025] = uint256(312500 * 1 ether); // Month 34
        _tokenAllocation["DevsTeam"][May_01_2025] = uint256(312500 * 1 ether); // Month 35
        _tokenAllocation["DevsTeam"][June_01_2025] = uint256(312500 * 1 ether); // Month 36

        //Advisor, Monthly Vesting = 36 Months
        _tokenAllocation["Advisor"][July_01_2022] = uint256(312500 * 1 ether); // Month 1
        _tokenAllocation["Advisor"][August_01_2022] = uint256(312500 * 1 ether);  // Month 2
        _tokenAllocation["Advisor"][September_01_2022] = uint256(312500 * 1 ether); // Month 3
        _tokenAllocation["Advisor"][October_01_2022] = uint256(312500 * 1 ether); // Month 4
        _tokenAllocation["Advisor"][November_01_2022] = uint256(312500 * 1 ether); // Month 5
        _tokenAllocation["Advisor"][December_01_2022] = uint256(312500 * 1 ether); // Month 6 
        _tokenAllocation["Advisor"][January_01_2023] = uint256(312500 * 1 ether); // Month 7
        _tokenAllocation["Advisor"][February_01_2023] = uint256(312500 * 1 ether); // Month 8
        _tokenAllocation["Advisor"][March_01_2023] = uint256(312500 * 1 ether); // Month 9
        _tokenAllocation["Advisor"][April_01_2023] = uint256(312500 * 1 ether); // Month 10
        _tokenAllocation["Advisor"][May_01_2023] = uint256(312500 * 1 ether); // Month 11
        _tokenAllocation["Advisor"][June_01_2023] = uint256(312500 * 1 ether); // Month 12
        _tokenAllocation["Advisor"][July_01_2023] = uint256(312500 * 1 ether); // Month 13
        _tokenAllocation["Advisor"][August_01_2023] = uint256(312500 * 1 ether); // Month 14
        _tokenAllocation["Advisor"][September_01_2023] = uint256(312500 * 1 ether); // Month 15
        _tokenAllocation["Advisor"][October_01_2023] = uint256(312500 * 1 ether); // Month 16
        _tokenAllocation["Advisor"][November_01_2023] = uint256(312500 * 1 ether); // Month 17
        _tokenAllocation["Advisor"][December_01_2023] = uint256(312500 * 1 ether); // Month 18
        _tokenAllocation["Advisor"][January_01_2024] = uint256(312500 * 1 ether); // Month 19
        _tokenAllocation["Advisor"][February_01_2024] = uint256(312500 * 1 ether); // Month 20
        _tokenAllocation["Advisor"][March_01_2024] = uint256(312500 * 1 ether); // Month 21
        _tokenAllocation["Advisor"][April_01_2024] = uint256(312500 * 1 ether); // Month 22
        _tokenAllocation["Advisor"][May_01_2024] = uint256(312500 * 1 ether); // Month 23
        _tokenAllocation["Advisor"][June_01_2024] = uint256(312500 * 1 ether); // Month 24
        _tokenAllocation["Advisor"][July_01_2024] = uint256(312500 * 1 ether); // Month 25
        _tokenAllocation["Advisor"][August_01_2024] = uint256(312500 * 1 ether); // Month 26
        _tokenAllocation["Advisor"][September_01_2024] = uint256(312500 * 1 ether); // Month 27
        _tokenAllocation["Advisor"][October_01_2024] = uint256(312500 * 1 ether); // Month 28
        _tokenAllocation["Advisor"][November_01_2024] = uint256(312500 * 1 ether); // Month 29
        _tokenAllocation["Advisor"][December_01_2024] = uint256(312500 * 1 ether); // Month 30
        _tokenAllocation["Advisor"][January_01_2025] = uint256(312500 * 1 ether); // Month 31
        _tokenAllocation["Advisor"][February_01_2025] = uint256(312500 * 1 ether); // Month 32
        _tokenAllocation["Advisor"][March_01_2025] = uint256(312500 * 1 ether); // Month 33
        _tokenAllocation["Advisor"][April_01_2025] = uint256(312500 * 1 ether); // Month 34
        _tokenAllocation["Advisor"][May_01_2025] = uint256(312500 * 1 ether); // Month 35
        _tokenAllocation["Advisor"][June_01_2025] = uint256(312500 * 1 ether); // Month 36

		//PlayToEarn, Monthly Vesting = 5 Months
        _tokenAllocation["PlayToEarn"][July_01_2022] = uint256(18400000 * 1 ether); // Month 1
        _tokenAllocation["PlayToEarn"][August_01_2022] = uint256(18400000 * 1 ether); // Month 2
        _tokenAllocation["PlayToEarn"][September_01_2022] = uint256(18400000 * 1 ether); // Month 3
        _tokenAllocation["PlayToEarn"][October_01_2022] = uint256(18400000 * 1 ether); // Month 4
        _tokenAllocation["PlayToEarn"][November_01_2022] = uint256(18400000 * 1 ether); // Month 5

        //Staking
        _tokenAllocation["Staking"][December_01_2022] = uint256(10000000 * 1 ether); //6 months After Liquidity
    
	}

    function initialTransfer() private {

        _transfer(address(this),_groupsAddress["Liquidity"],uint256(5000000 * 1 ether)); // Liquidity
        _transfer(address(this),_groupsAddress["Development"],uint256(2000000 * 1 ether)); // Development 
        _transfer(address(this),_groupsAddress["DevsTeam"],uint256(1250000 * 1 ether)); // DevsTeam
        _transfer(address(this),_groupsAddress["Advisor"],uint256(1250000 * 1 ether)); // Advisor
        _transfer(address(this),_groupsAddress["PlayToEarn"],uint256(23000000 * 1 ether)); // PlayToEarn
				
    }

    /**
     * Modifiers
     */
    modifier onlyAdmin() {
        // Is Admin?
        require(_admin == msg.sender);
        _;
    }

    modifier isPrivateSaleContract() {
        require(msg.sender == _privateSaleContract);
        _;
    }

    modifier isPresaleContract() {
        require(msg.sender == _presaleContract);
        _;
    }

    modifier isSwapContract() {
        require(msg.sender == _swapContract);
        _;
    }

    modifier whenPaused() {
        // Is pause?
        require(_isPaused, "Pausable: not paused Erc20");
        _;
    }

    modifier whenNotPaused() {
        // Is not pause?
        require(!_isPaused, "Pausable: paused Erc20");
        _;
    }

    // Transfer ownernship
    function transferOwnership(address payable admin) external onlyAdmin {
        require(admin != address(0), "Zero address");
        _admin = admin;
    }

    /**
     * Update privatesale contract
     */
    function _setPrivateSaleContract(address privateSaleContractAddress)
        external
        onlyAdmin
    {
        require(privateSaleContractAddress != address(0), "Zero address");
        _privateSaleContract = privateSaleContractAddress;
    }

    /**
     * Update presale contract
     */
    function _setPresaleContract(address presaleContractAddress)
        external
        onlyAdmin
    {
        require(presaleContractAddress != address(0), "Zero address");
        _presaleContract = presaleContractAddress;
    }
    /**
     * Update swapping contract
     */
    function _setSwapContract(address swappingContractAddress)
        external
        onlyAdmin
    {
        require(swappingContractAddress != address(0), "Zero address");
        _swapContract = swappingContractAddress;
    }

    /**
     * ERC20 functions
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    /**
     * @dev Automically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Automically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(!_isPaused, "ERC20Pausable: token transfer  le paused");
        require(
            !_isPausedAddress[sender],
            "ERC20Pausable: token transfer while paused on address"
        );
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            recipient != address(this),
            "ERC20: transfer to the token contract address"
        );

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * External contract transfer functions
     */
    // Allow privatesale external contract to trigger transfer function
    function transferPrivateSale(address recipient, uint256 amount)
        external
        isPrivateSaleContract
        returns (bool)
    {
        require(
            _privateSaleAmountCap.sub(amount) >= 0,
            "No more amount allocated for privatesale"
        );
        _privateSaleAmountCap = _privateSaleAmountCap.sub(amount);
        _transfer(address(this), recipient, amount);
        return true;
    }

    /**
     * External contract transfer functions
     */
    // Allow presale external contract to trigger transfer function
    function transferPresale(address recipient, uint256 amount)
        external
        isPresaleContract
        returns (bool)
    {
        require(
            _presaleAmountCap.sub(amount) >= 0,
            "No more amount allocated for presale"
        );
        _presaleAmountCap = _presaleAmountCap.sub(amount);
        _transfer(address(this), recipient, amount);
        return true;
    }

    /**
     * External contract transfer functions
     */
    // Allow swapping external contract to trigger transfer function
    function swapToken(address recipient, uint256 amount)
        external
        isSwapContract
        returns (bool)
    {
        require(
            _swapAmountCap.sub(amount) >= 0,
            "No more amount allocated for swapping"
        );
        _swapAmountCap = _swapAmountCap.sub(amount);
        _transfer(address(this), recipient, amount);
        return true;
    }

	//Token Vesting
    function tokenVesting() external {
        for (uint256 i = 0; i < _groups.length; i++) {
            address groupAddress = _groupsAddress[_groups[i]];
            for (uint256 y = 0; y < _dates.length; y++) {
                uint256 amount = _tokenAllocation[_groups[i]][_dates[y]];
                if (block.timestamp >= _dates[y]) {
                    bool hasDistributed = _tokenAllocationStatus[_groups[i]][_dates[y]][amount];
                    if (!hasDistributed) {
                        bool canTransfer = _groupsTransfer(groupAddress,amount,_groups[i]);
                        if (canTransfer) {
                            _tokenAllocationStatus[_groups[i]][_dates[y]][amount] = true;
                        }
                    }
                }
            }
        }
    }

    function _groupsTransfer(
        address recipient,
        uint256 amount,
        string memory categories
    ) private returns (bool) {
        if (_groupsAmountCap[categories] < amount) {
            emit OutOfMoney(categories);
            return false;
        }
        _groupsAmountCap[categories] = _groupsAmountCap[categories].sub(amount);
        _transfer(address(this), recipient, amount);
        return true;
    }

    function pause() external onlyAdmin whenNotPaused {
        _isPaused = true;
    }

    function unpause() external onlyAdmin whenPaused {
        _isPaused = false;
    }

    function pausedAddress(address sender) external onlyAdmin {
        _isPausedAddress[sender] = true;
    }

    function unPausedAddress(address sender) external onlyAdmin {
        _isPausedAddress[sender] = false;
    }

    function burnToken(uint256 amount) external onlyAdmin {
        _transfer(address(this), _deadAddress, amount);
    }

    receive() external payable {
        revert();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
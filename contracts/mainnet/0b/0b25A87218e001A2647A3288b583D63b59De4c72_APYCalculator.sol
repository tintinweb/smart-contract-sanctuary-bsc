/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPCSMasterChef {
    function totalRegularAllocPoint() external view returns (uint256);
    function totalSpecialAllocPoint() external view returns (uint256);
    function poolInfo(uint256 index) external view returns (uint256, uint256, uint256, uint256, bool);
    function lpToken(uint256 index) external view returns (address);
    function cakePerBlock(bool isRegular) external view returns (uint256);
}

interface Oracle {
    function priceOf(address token) external view returns (uint256);
}

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract APYCalculator {

    // Master Chef
    IPCSMasterChef constant chef = IPCSMasterChef(0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652);

    // Price Oracle
    Oracle oracle = Oracle(0x952B02F1973a1157cfE1B43d62aC6E1e921C5D00);

    // cake token
    address constant cake = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    struct Yield {
        uint allocation;
        uint index;
    }

    // PID => Allocation
    mapping ( uint256 => Yield ) public pids;

    // all pids
    uint256[] public allPids;

    // total allocation points
    uint public totalAllocation;

    mapping ( address => bool ) public changer;
    modifier onlyChanger(){
        require(changer[msg.sender]);
        _;
    }

    constructor(){
        changer[msg.sender] = true;
    }

    function setChanger(address changer_, bool isChanger) external onlyChanger {
        changer[changer_] = isChanger;
    }

    function registerYield(uint PID, uint allocation) external onlyChanger{
        pids[PID].allocation = allocation;
        pids[PID].index = allPids.length;
        totalAllocation += allocation;
        allPids.push(PID);
    }

    function changeAllocation(uint PID, uint nAllocation) external onlyChanger{
        totalAllocation = totalAllocation - pids[PID].allocation + nAllocation;
        pids[PID].allocation = nAllocation;
    }

    function removeYield(uint PID) external onlyChanger{

        pids[
            allPids[allPids.length - 1]
        ].index = pids[PID].index;

        allPids[
            pids[PID].index
        ] = allPids[allPids.length - 1];
        allPids.pop();
        
        totalAllocation -= pids[PID].allocation;
        delete pids[PID];
    }

    function getTotalRate() public view returns (uint256) {
        uint tot = 0;
        for (uint i = 0; i < allPids.length; i++) {
            tot += pids[allPids[i]].allocation * getDailyRate(allPids[i]);
        }
        return tot / totalAllocation;
    }

    function getDailyRate(uint256 PID) public view returns (uint256) {
        uint rate = valueGivenPerDay(PID);
        uint valueLocked = getValueLocked(PID);
        return ( (rate * 10**18 ) / valueLocked );
    }

    function getValueLocked(uint256 PID) public view returns (uint256) {
        (address token0, address token1, address LP) = fetchTokensAndLP(PID);
        
        uint qty0 = IERC20(token0).balanceOf(LP);
        uint qty1 = IERC20(token1).balanceOf(LP);

        return ((oracle.priceOf(token0) * qty0 / 10**IERC20(token0).decimals()) + (oracle.priceOf(token1) * qty1 / 10**IERC20(token1).decimals()));
    }

    function fetchTokensAndLP(uint256 PID) public view returns (address,address,address) {
        address LP = chef.lpToken(PID);
        address t0 = IPair(LP).token0();
        address t1 = IPair(LP).token1();
        return (t0,t1,LP);
    }

    function valueGivenPerDay(uint256 PID) public view returns (uint256) {
        (uint allocation, bool isRegular) = getAllocationPoints(PID);
        uint totAlloc = isRegular ? totalRegularAllocationPoints() : totalSpecialAllocationPoints();
        uint cakePerDay = ( allocation * getDailyCake(isRegular) ) / totAlloc;
        return cakePerDay * oracle.priceOf(cake);
    }

    function getAllocationPoints(uint256 PID) public view returns (uint256 points, bool regular) {
        (,,,points,regular) = chef.poolInfo(PID);
    }

    function totalRegularAllocationPoints() public view returns (uint256) {
        return chef.totalRegularAllocPoint();
    }

    function totalSpecialAllocationPoints() public view returns (uint256) {
        return chef.totalSpecialAllocPoint();
    }

    function getDailyCake(bool isRegular) public view returns (uint256) {
        return chef.cakePerBlock(isRegular) * 28800;
    }
}
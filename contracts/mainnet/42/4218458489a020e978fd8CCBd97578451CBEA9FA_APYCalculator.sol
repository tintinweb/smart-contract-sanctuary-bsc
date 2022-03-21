/**
 *Submitted for verification at BscScan.com on 2022-03-21
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
    function totalAllocPoint() external view returns (uint256);
    function poolInfo(uint256 index) external view returns (address, uint256, uint256, uint256);
    function cakePerBlock() external view returns (uint256);
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
    IPCSMasterChef constant chef = IPCSMasterChef(0x73feaa1eE314F8c655E354234017bE2193C9E24E);

    // Price Oracle
    Oracle oracle = Oracle(0x952B02F1973a1157cfE1B43d62aC6E1e921C5D00);

    // cake token
    address constant cake = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    // syrup token
    address constant syrup = 0x009cF7bC57584b7998236eff51b98A168DceA9B0;

    function valueOfStakedCakeFor(address user) external view returns (uint256) {
        return ( oracle.priceOf(cake) * IERC20(syrup).balanceOf(user) ) / 10**18;
    }

    function valueOfStakedCakeForDonation() external view returns (uint256) {
        return ( oracle.priceOf(cake) * IERC20(syrup).balanceOf(0x65005eAB0c6add350F43032a6cB776E38eADc3B7) ) / 10**18;
    }

    function getDailyRate() public view returns (uint256) {
        uint rate = valueGivenPerDay();
        uint valueLocked = getValueLocked();
        return ( (rate * 10**18 ) / valueLocked );
    }

    function getValueLocked() public view returns (uint256) {
        uint qty = IERC20(cake).balanceOf(address(chef));
        return (oracle.priceOf(cake) * qty ) / 10**18;
    }

    function valueGivenPerDay() public view returns (uint256) {
        uint cakePerDay = ( getAllocationPoints() * getDailyCake() ) / totalAllocationPoints();
        return cakePerDay * oracle.priceOf(cake);
    }

    function getAllocationPoints() public view returns (uint256 points) {
        (,points,,) = chef.poolInfo(0);
    }

    function totalAllocationPoints() public view returns (uint256) {
        return chef.totalAllocPoint();
    }

    function getDailyCake() public view returns (uint256) {
        return chef.cakePerBlock() * 28800;
    }
}
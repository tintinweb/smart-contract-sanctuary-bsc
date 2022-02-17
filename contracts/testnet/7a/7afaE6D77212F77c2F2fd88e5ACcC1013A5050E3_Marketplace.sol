pragma solidity >=0.4.22 <0.9.0;

contract Marketplace {
    struct PowerAddress {
        address wallet;
        uint256 fees;
    }

    address owner;

    constructor() {
        owner = msg.sender;
    }

    PowerAddress[] public powerAddresses;

    modifier onlyMarketplace() {
        require(owner == msg.sender);
        _;
    }

    function addPowerAddress(address _wallet, uint256 _fee) public onlyMarketplace returns (bool) {
        powerAddresses.push(PowerAddress({
            wallet: _wallet,
            fees: _fee
        }));
        return true;
    }

    function removePowerAddress(address _wallet) public onlyMarketplace returns (bool) {
        for (uint256 i = 0; i < powerAddresses.length; i++) {
            if (powerAddresses[i].wallet == _wallet) {
                delete powerAddresses[i];
                return true;
            }
        }
        return false;
    }

    function usageOfAlgorithm(uint256 difficulty) public {
        for (uint256 i = 0; i < powerAddresses.length; i++) {
            payable(powerAddresses[i].wallet).transfer(powerAddresses[i].fees * difficulty);
        }
    }

    function editPowerAddressFees(address _wallet, uint256 _fee) public onlyMarketplace returns (bool) {
        for (uint256 i = 0; i < powerAddresses.length; i++) {
            if (powerAddresses[i].wallet == _wallet) {
                powerAddresses[i].fees = _fee;
                return true;
            }
        }
        return false;
    }
}
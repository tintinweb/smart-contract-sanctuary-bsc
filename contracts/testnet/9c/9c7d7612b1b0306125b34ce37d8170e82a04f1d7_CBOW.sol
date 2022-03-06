// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract CBOW is ERC20, Ownable {
    uint256 public maxSupply = 100000000 * 1e18;

    mapping(address => bool) public allowedAddresses;

    uint256 public transferLimit;
    bool public antiWhaleActivated;

    address rewardPoolAddress = 0xF6eb68D6A857EdbdaF05DAB7Dec05ab258Ad7223;
    address marketingAddress = 0x22294F18820C6c0158Beb4A64990A96d855E9C25;
    address liquidityAddress = 0x57dfd7A3D7AC479a11F139445D92F5438F5E03b4;
    address teamAddress = 0x7276823580304fCF2BEEAF171e6EaA14B493B648;
    address publicSaleAddress = 0x28Ee13B9f4cACACF1354d14e7f238eab013eeC6F;
    address privateSaleAddress = 0x0Cf5AD01B31AA9c19A1feb7e595acB01F65F0aC9;
    address airdropAddress = 0x9A0389Abe390b3d8dF6fcC9723C215Ab8Ef00a4c;
    
    uint256 rewardPoolAllocation = 65000000 * 1e18;
    uint256 marketingAllocation = 10000000 * 1e18;
    uint256 liquidityAllocation = 8000000 * 1e18;
    uint256 teamAllocation = 6000000 * 1e18;
    uint256 publicSaleAllocation = 5000000 * 1e18;
    uint256 privateSaleAllocation = 5000000 * 1e18;
    uint256 airdropAllocation = 1000000 * 1e18;
    
    constructor() ERC20("Cryptobows", "CBOW") {
        _mint(rewardPoolAddress, rewardPoolAllocation);
        _mint(marketingAddress, marketingAllocation);
        _mint(liquidityAddress, liquidityAllocation);
        _mint(teamAddress, teamAllocation);
        _mint(publicSaleAddress, publicSaleAllocation);
        _mint(privateSaleAddress, privateSaleAllocation);
        _mint(airdropAddress, airdropAllocation);
    }
    
    //Checks if a wallet is attemption to transfer more than the transfer limit
    function isWhale(address _from, address _to, uint256 _amount) public view returns (bool) {
        if (
            msg.sender == owner() ||
            antiWhaleActivated == false ||
            _amount <= transferLimit ||
            _from == rewardPoolAddress ||
            _to == rewardPoolAddress
        ) {
            return false;
        } else {
            return true;
        }
    }

    //Set transfer limit for antiwhale protection
    function setAntiWhaleTransferLimit(uint256 _transferLimit) public onlyOwner {
        transferLimit = _transferLimit;
        antiWhaleActivated = true;
    }

    //Set antiwhale activation status
    function setAntiWhaleActivationStatus(bool _status) public onlyOwner {
        require(!antiWhaleActivated == _status);
        antiWhaleActivated = _status;
    }

    //Set rewards pool address in case it needs to be changed
    function setRewardPoolAddress(address _rewardPoolAddress) public onlyOwner {
        rewardPoolAddress = _rewardPoolAddress;
    }

    //Transfer overide for antiwhale detection
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override {
        super._beforeTokenTransfer(_from, _to, _amount);

        require(!isWhale(_from, _to, _amount), "AntiWhale");
    }

}
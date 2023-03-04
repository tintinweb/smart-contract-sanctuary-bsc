// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MarsMinerToken.sol";

contract MarsMinerTokenManager is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    address public minter;
    MarsMinerToken public marsMinerToken;

    modifier onlyMinter {
        require(_msgSender() == minter, "only minter");
        _;
    }

    constructor(address _mmtAddress, address _minter) {
        require(_minter != address(0), "err:minter zero");
        require(_minter != msg.sender, "err:minter==owner");
        minter = _minter;
        marsMinerToken = MarsMinerToken(_mmtAddress);
    }

    function setMMTAddress(address _mmtAddress) external onlyOwner nonReentrant {
        require(_mmtAddress != address(0), "err: zero address");
        require(Address.isContract(_mmtAddress), "err: not a contract");
        require(address(marsMinerToken) != _mmtAddress, "err: already mmt address");
        marsMinerToken = MarsMinerToken(_mmtAddress);
    }

    function setMinter(address _to) external onlyOwner nonReentrant {
        require(_to != address(0), "err:to zero");
        require(_to != minter, "err:already minter");
        minter = _to;
    }

    function mintMMT(address _to, uint256 _amount) external onlyMinter nonReentrant {
        require(_to != address(0), "err:to zero");
        require(_amount > 0, "err:amount zero");
        marsMinerToken.mint(_to, _amount);
    }

    function withdrawToken(address _token, uint256 _amount, address _to) external onlyOwner nonReentrant {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "ERR: insuff token");
        require(IERC20(_token).transfer(_to, _amount), "ERR: transfer token");
    }
}
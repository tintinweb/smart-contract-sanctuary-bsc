// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InvestorManager {
  struct Investor {
    address investorAddress;
    address presenterAddress;
    uint256 tokenSwapped;
    uint256 level;
  }

  mapping(address => Investor) public investors;

  event CreateInvestor(address investorAddress, address presenterAddress);

  function createInvestor(address investorAddress, address presenterAddress) internal {
    investors[investorAddress] = Investor({
      investorAddress: investorAddress,
      presenterAddress: presenterAddress,
      tokenSwapped: 0,
      level: investors[presenterAddress].level + 1
    });
    emit CreateInvestor(investorAddress, presenterAddress);
  }

  function createNormalUser(address investorAddress, address presenterAddress) internal {
    if (isInvestor(investorAddress)) return;
    require(isInvestor(presenterAddress), "PRESENTER_NOT_FOUND");
    createInvestor(investorAddress, presenterAddress);
  }

  function isInvestor(address presenterAddress) public view returns (bool) {
    return investors[presenterAddress].level != 0;
  }
}

contract IDO is InvestorManager {
  IERC20 public ncfToken;
  address public owner;

  constructor(IERC20 _ncfToken) {
    ncfToken = _ncfToken;
    owner = msg.sender;
    createInvestor(owner, address(0));
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "ONLY_OWNER");
    _;
  }

  uint256 public price = 200000;

  function setPrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function normalizePresenterAddress(address presenterAddress) internal view returns (address) {
    if (presenterAddress != address(0)) return presenterAddress;
    return owner;
  }

  function buyToken(address presenterAddress) public payable {
    createNormalUser(msg.sender, normalizePresenterAddress(presenterAddress));
    Investor storage investor = investors[msg.sender];
    uint256 ncfValue = msg.value / price;
    investor.tokenSwapped += ncfValue;
    payWithCommission(msg.sender, ncfValue);
  }

  mapping(address => bool) public claimed;

  function claim(address presenterAddress) public {
    require(!claimed[msg.sender], "ALREADY_CLAIMED");
    createNormalUser(msg.sender, normalizePresenterAddress(presenterAddress));
    claimed[msg.sender] = true;
    payWithCommission(msg.sender, 1000 gwei);
  }

  uint256 public totalPayout = 0;

  function payWithCommission(address receiver, uint256 value) internal {
    Payment[] memory payments = getPayments(receiver, value);
    uint256 payout = 0;
    for (uint256 index = 0; index < payments.length; index++) {
      Payment memory payment = payments[index];
      if (payment.value == 0 || payment.receiver == address(0)) continue;
      ncfToken.transfer(payment.receiver, payment.value);
      payout += payment.value;
    }
    totalPayout += payout;
  }

  struct Payment {
    uint256 value;
    address receiver;
  }

  uint256 public TOKEN_SWAPPED_TO_RECEIVE_COMMISSION_FROM_F2_AND_F7 = 50000 gwei;

  function getPayments(address receiver, uint256 value)
    private
    view
    returns (Payment[] memory result)
  {
    uint256[8] memory rates = [uint256(0), 5, 4, 4, 3, 2, 1, 1];
    result = new Payment[](8);
    result[0] = Payment({receiver: receiver, value: value});

    Investor memory presenter = getPresenter(receiver);
    result[1] = Payment({receiver: presenter.investorAddress, value: (value * rates[1]) / 100});

    for (uint256 count = 2; count <= 7; count++) {
      address presenterAddress = presenter.investorAddress;
      if (presenterAddress == address(0)) return result;

      presenter = getPresenter(presenterAddress);
      if (presenter.tokenSwapped >= TOKEN_SWAPPED_TO_RECEIVE_COMMISSION_FROM_F2_AND_F7) {
        result[count] = Payment({
          receiver: presenter.investorAddress,
          value: (value * rates[count]) / 100
        });
      }
    }

    return result;
  }

  function getPresenter(address investorAddress) private view returns (Investor memory) {
    address presenterAddress = investors[investorAddress].presenterAddress;
    return investors[presenterAddress];
  }

  function withdrawBNB() public onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function withdrawNCF(uint256 amount) public onlyOwner {
    ncfToken.transfer(msg.sender, amount);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public TAX_PERCENT = 1; // in percent 1 = 1%;
    address public TAX_COLLECTOR_WALLET;

    mapping(address => bool) public isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor() ERC20("MyToken", "MTK") {
        uint256 totalSupply = 8000000 * 10 ** decimals();
        TAX_COLLECTOR_WALLET = msg.sender;
        isExcludedFromFees[msg.sender] = true;
        _mint(msg.sender, totalSupply);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint256 amountToTransfer = amount;

        bool takeFee = true;

        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 taxAmount = calculateTax(amount);
            super._transfer(from, TAX_COLLECTOR_WALLET, taxAmount);
            amountToTransfer = amount - taxAmount;
        }
        super._transfer(from, to, amountToTransfer);
    }



    function calculateTax(uint256 totalAmount) internal view returns (uint256) {
        return totalAmount.mul(TAX_PERCENT).div(100);
    }

}

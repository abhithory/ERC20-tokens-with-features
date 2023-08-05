// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract ERC20PresaleAirdrop is ERC20, Ownable {
    using SafeMath for uint256;


    uint256 TOTAL_SUPPLY = 800000 * (10 ** decimals()); 

    // FOR AIRDROP
    bool public IS_AIRDROP_ACTIVE = true;
    uint256 public AIRDROP_FEE_ETH = 1 * 10 ** (decimals() - 6); // 0.000001
    uint256 public AIRDROP_WALLET_AMOUNT = 1000 * (10 ** decimals());
    uint256 public AIRDROP_MAX_SUPPLY = 10_000 * (10 ** decimals()); // 0.0001
    uint256 public AIRDROP_CURRENT_SUPPLY = 0;
    mapping(address => bool) public airdropClaimed;

    // FOR PRESALE
    bool public IS_PRESALE_ACTIVE = true;
    uint256 public PRESALE_TOKEN_PRICE_ETH = 1 * (10 ** (decimals() - 6)); // 0.000001
    uint256 public PRESALE_WALLET_AMOUNT_LIMIT = 50 * (10 ** decimals());
    uint256 public PRESALE_MAX_SUPPLY = 1000 * (10 ** decimals()); // 0.0001
    uint256 public PRESALE_CURRENT_SUPPLY = 0;
    mapping(address => uint256) public presaleClaimedAmount;
    mapping(address => bool) public isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor(address admin) ERC20("Don", "DP") {
        transferOwnership(admin);
        
        // isExcludedFromFees[msg.sender] = true;

        uint256 mintAmountContract = PRESALE_MAX_SUPPLY + AIRDROP_MAX_SUPPLY;
        _mint(address(this), mintAmountContract);
        uint256 mintAmountToUser = TOTAL_SUPPLY - mintAmountContract;
        _mint(admin, mintAmountToUser);
    }

    function transferContractToken(
        address _to,
        uint256 amount
    ) public onlyOwner {
        super._transfer(address(this), _to, amount);
    }

    function changeTexCollector(address _address) public onlyOwner {
        TAX_COLLECTOR_WALLET = _address;
    }

    function changePresaleStatus() public onlyOwner {
        IS_PRESALE_ACTIVE = !IS_PRESALE_ACTIVE;
    }

    function changeAirdropStatus() public onlyOwner {
        IS_AIRDROP_ACTIVE = !IS_AIRDROP_ACTIVE;
    }



    function ClaimAirdrop() public payable {
        require(IS_AIRDROP_ACTIVE, "Airdrop is not active currectly");
        require(
            !airdropClaimed[msg.sender],
            "You have already claimed your airdrop."
        );
        require(
            AIRDROP_CURRENT_SUPPLY + AIRDROP_WALLET_AMOUNT <=
                AIRDROP_MAX_SUPPLY,
            "All Airdrop tokens Claimed"
        );
        require(msg.value >= AIRDROP_FEE_ETH, "Please send fee for airdrop");

        airdropClaimed[msg.sender] = true;
        AIRDROP_CURRENT_SUPPLY += AIRDROP_WALLET_AMOUNT;
        super._transfer(address(this), msg.sender, AIRDROP_WALLET_AMOUNT);
    }

    function Presale(uint256 amount) public payable {
        require(IS_PRESALE_ACTIVE, "Presale is not active currectly");
        require(
            presaleClaimedAmount[msg.sender] + amount <=
                PRESALE_WALLET_AMOUNT_LIMIT,
            "You have already claimed all tokens in presale."
        );
        require(
            PRESALE_CURRENT_SUPPLY + amount <= PRESALE_MAX_SUPPLY,
            "All tokens sold in presale"
        );
        require(
            msg.value >=
                PRESALE_TOKEN_PRICE_ETH * (amount / (10 ** decimals())),
            "Please send fee for Presale"
        );

        presaleClaimedAmount[msg.sender] += amount;
        PRESALE_CURRENT_SUPPLY += amount;
        super._transfer(address(this), msg.sender, amount);
    }
}

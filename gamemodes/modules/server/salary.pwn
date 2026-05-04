//    Name detail : Ingame Salary
//    Made by     : Agus Syahputra
//    Date        : 23:30 - 16/04/2018

/*
    TODO: 
    -

    NOTE: 
    -
*/

#include <YSI\y_hooks>

/*
    Forward
*/

forward ShowingPlayerSalary(playerid);

/*
    Local Function
*/
AddPlayerSalary(userid, salary, issuer[]) {
    if(!IsPlayerConnected(userid)) {
        return 0;
    }

    if(salary < 0) {
        salary = 0;
    }

    new query[255];
    mysql_format(g_iHandle, query,sizeof(query),"INSERT INTO `salary` SET `LinkID`='%d', `Money`='%d', `Issue`='%s', `Date`=UNIX_TIMESTAMP()", PlayerData[userid][pID], salary, issuer);
    mysql_tquery(g_iHandle, query, "OnSalaryAdded", "d", userid);
    return 1;
}

GetSalaryMoney(playerid, &money)
{
    new
        Cache:salary_cache,
        bool:null,
        query[128];

    mysql_format(g_iHandle, query, sizeof(query), "SELECT SUM(Money) AS `Total` FROM `salary` WHERE `LinkID`='%d'", GetPlayerSQLID(playerid));
    salary_cache = mysql_query(g_iHandle, query);

    if(cache_num_rows()) {
        cache_is_value_null(0, "Total", null);
        if (!null) cache_get_value_int(0, "Total", money);
        else money = 0;
    }
    cache_delete(salary_cache);
    return 1;
}

GivePlayerSalary(playerid)
{
    static
        salary_money = 0;

    GetSalaryMoney(playerid, salary_money);
    AddBankMoney(playerid, salary_money);
    ClearPlayerSalary(playerid);
    return 1;
}

ShowPlayerSalary(playerid) {
    new string[5000], query[128], Cache: checksalary, Cache: check,count = 0, total, bool:null;
    format(query,sizeof(query),"SELECT SUM(Money) AS Total FROM salary WHERE `LinkID`='%d'", PlayerData[playerid][pID]);
    check = mysql_query(g_iHandle, query);

    new rowss = cache_num_rows();
    if(rowss) {
        cache_is_value_null(0, "Total", null);
        if (!null) cache_get_value_int(0, "Total", total);
        else total = 0;
    }
    cache_delete(check);

    format(query,sizeof(query),"SELECT Money, Issue, Date FROM salary WHERE `LinkID`='%d'", PlayerData[playerid][pID]);
    checksalary = mysql_query(g_iHandle, query);

    new rows = cache_num_rows();
    format(string,sizeof(string), "Time\tFrom\tAmount\n");
    for(new i; i != rows; i++)
    {
        new 
            issuer[128],
            date,
            money;

        cache_get_value(i, "Issue", issuer, sizeof(issuer));
        cache_get_value_int(i, "Date", date);
        cache_get_value_int(i, "Money", money);

        format(string,sizeof(string), "%s%s\t%s\t$%s\n", string, GetDuration(gettime()-date), issuer, FormatNumber(money));
        count++;
    }

    if(count) Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, sprintf(""WHITE"Salary: "GREEN"$%s", FormatNumber(total)), string, "Close", "");
    else SendErrorMessage(playerid, "You dont have pending salary.");

    cache_delete(checksalary);
    return 1;
}

/*ShowCheckSalary(playerid, userid) {
    new string[5000], query[128], Cache: checksalary, Cache: check,count = 0, total;
    format(query,sizeof(query),"SELECT SUM(Money) As Total FROM salary WHERE `LinkID`='%d'", PlayerData[userid][pID]);
    check = mysql_query(g_iHandle, query);

    new rowss = cache_num_rows();
    if(rowss) {
        total = cache_get_value_int(0, "Total");
    }
    cache_delete(check);

    format(query,sizeof(query),"SELECT Money, Issue, Date FROM salary WHERE `LinkID`='%d'", PlayerData[userid][pID]);
    checksalary = mysql_query(g_iHandle, query);

    new rows = cache_num_rows();
    format(string,sizeof(string), "Time\tFrom\tAmount\n");
    for(new i; i != rows; i++)
    {
        new 
            issuer[128];

        cache_get_value(i, "Issue", issuer, sizeof(issuer));
        format(string,sizeof(string), "%s%s\t%s\t%s\n", string, GetDuration(gettime()-cache_get_value_int(i, "Date")), issuer, FormatNumber(cache_get_value_int(i, "Money")));
        count++;
    }

    if(count) Dialog_Show(playerid, ShowOnly, DIALOG_STYLE_TABLIST_HEADERS, sprintf(""WHITE"Salary: "GREEN"%s", FormatNumber(total)), string, "Close", "");
    else SendErrorMessage(playerid, "That player dont have pending salary.");

    cache_delete(checksalary);
    return 1;
}*/

ClearPlayerSalary(playerid) {
    mysql_tquery(g_iHandle, sprintf("DELETE FROM `salary` WHERE `LinkID`='%d';", GetPlayerSQLID(playerid))); 
    return 1;
}

/*
    Callback
*/
Function:OnSalaryAdded(playerid) {
    return SendServerMessage(playerid, "Daftar gaji kamu telah di tambahkan, kamu dapat melihatnya pada perintah "YELLOW"/salary.");
}


/*
    Commands
*/
CMD:salary(playerid, params[])
{
    ShowPlayerSalary(playerid);
    return 1;
}

/*CMD:checksalary(playerid, params[])
{
    static 
        userid;

    if(sscanf(params, "u", userid))
        return SendSyntaxMessage(playerid, "/checksalary [PlayerID / Nickname]");

    if(!IsPlayerConnected(userid))
        return SendErrorMessage(playerid, "That player isn't connected!");

    ShowCheckSalary(playerid, userid);
    return 1;
}*/

CMD:addsalary(playerid, params[])
{
    if (CheckAdmin(playerid, 4))
        return PermissionError(playerid);

    static
        userid,
        salary,
        issuer[32];

    if(sscanf(params, "uds[32]", userid, salary, issuer))
        return SendSyntaxMessage(playerid, "/addsalary [playerid] [salary] [issue]");

    if(!IsPlayerConnected(userid))
        return SendErrorMessage(playerid, "That player isn't connected!");

    if(salary < 1 || salary > 50000)
        return SendErrorMessage(playerid, "Refund salary can't be more than 50000 or below than 1!");

    
    AddPlayerSalary(userid, salary, issuer);
    SendCustomMessage(playerid, "SALARY", "You have sent a salary with nominal "GREEN"$%d"WHITE" to "YELLOW"%s for %s", salary, ReturnName(userid), issuer);
    Log_Write("logs/addsalary.txt", "[%s] %s has added salary [$%d] to: %s for %s issue.", ReturnDate(), ReturnName(playerid), salary, ReturnName(userid), issuer);
    return 1;
}

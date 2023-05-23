<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	// 현재페이지
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	// oracle db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "HR";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	// 전체 행의 수 구하는 sql
	PreparedStatement totalRowStmt = null;
	ResultSet totalRowRs = null;
	String totalRowSql = "select count(*) from employees";
	totalRowStmt = conn.prepareStatement(totalRowSql);
	totalRowRs = totalRowStmt.executeQuery();
	// 페이지 당 행의 수
	int rowPerPage = 10;
	// 시작 행 번호
	int beginRow = (currentPage-1) * rowPerPage + 1;
	// 마지막 행 번호
	int endRow = beginRow + rowPerPage - 1;
	// 전체 행의 수
	int totalRow = 0;
	if(totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1);
	}
	// 마지막 행 번호 > 전체 행의 수 -> 마지막 행 번호 = 전체 행의 수
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	// 마지막 페이지 번호
	int lastPage = totalRow / rowPerPage;
	// 표시하지 못한 행이 있을 경우 페이지 + 1
	if(totalRow % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	
	// rank sql 전송
	String rankSql = "select 번호, 이름, 급여, 순위 from (select rownum 번호, 이름, 급여, 순위 from (select first_name 이름, salary 급여, rank() over(order by salary) 순위 from employees)) where 번호 between ? and ?";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1,beginRow);
	rankStmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(rankStmt + " <-- rank_ntile_list rankStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	ResultSet rankRs = rankStmt.executeQuery();
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<HashMap<String, Object>>();
	while(rankRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", rankRs.getString("번호")); 
		m.put("이름", rankRs.getString("이름"));
		m.put("급여", rankRs.getString("급여"));
		m.put("순위", rankRs.getString("순위"));
		rankList.add(m);
	}
	// dense_rank sql 전송 
	String dense_rankSql = "select 번호, 이름, 급여, 순위 from (select rownum 번호, 이름, 급여, 순위 from (select first_name 이름, salary 급여, dense_rank() over(order by salary) 순위 from employees)) where 번호 between ? and ?";
	PreparedStatement dense_rankStmt = conn.prepareStatement(dense_rankSql);
	dense_rankStmt.setInt(1,beginRow);
	dense_rankStmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(dense_rankStmt + " <-- rank_ntile_list dense_rankStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	ResultSet dense_rankRs = dense_rankStmt.executeQuery();
	ArrayList<HashMap<String, Object>> dense_rankList = new ArrayList<HashMap<String, Object>>();
	while(dense_rankRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", dense_rankRs.getString("번호")); 
		m.put("이름", dense_rankRs.getString("이름"));
		m.put("급여", dense_rankRs.getString("급여"));
		m.put("순위", dense_rankRs.getString("순위"));
		dense_rankList.add(m);
	}	
	// row_number sql 전송 
	String row_numberSql = "select 번호, 이름, 급여, 순위 from (select rownum 번호, 이름, 급여, 순위 from (select first_name 이름, salary 급여, row_number() over(order by salary) 순위 from employees)) where 번호 between ? and ?";
	PreparedStatement row_numberStmt = conn.prepareStatement(row_numberSql);
	row_numberStmt.setInt(1,beginRow);
	row_numberStmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(row_numberStmt + " <-- rank_ntile_list row_numberStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	ResultSet row_numberRs = row_numberStmt.executeQuery();
	ArrayList<HashMap<String, Object>> row_numberList = new ArrayList<HashMap<String, Object>>();
	while(row_numberRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", row_numberRs.getString("번호")); 
		m.put("이름", row_numberRs.getString("이름"));
		m.put("급여", row_numberRs.getString("급여"));
		m.put("순위", row_numberRs.getString("순위"));
		row_numberList.add(m);
	}
	// ntile sql 전송 
	String ntileSql = "select 번호, 이름, 급여, 등급 from (select rownum 번호, 이름, 급여, 등급 from (select first_name 이름, salary 급여, ntile(10) over(order by salary desc) 등급 from employees)) where 번호 between ? and ?";
	PreparedStatement ntileStmt = conn.prepareStatement(ntileSql);
	ntileStmt.setInt(1,beginRow);
	ntileStmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(ntileStmt + " <-- rank_ntile_list ntileStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	ResultSet ntileRs = ntileStmt.executeQuery();
	ArrayList<HashMap<String, Object>> ntileList = new ArrayList<HashMap<String, Object>>();
	while(ntileRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", ntileRs.getString("번호")); 
		m.put("이름", ntileRs.getString("이름"));
		m.put("급여", ntileRs.getString("급여"));
		m.put("등급", ntileRs.getString("등급"));
		ntileList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="row">
	<div class="col-sm">
		<h1>rank</h1>
		<table class="table">
			<tr>
				<td>이름</td>
				<td>급여</td>
				<td>순위</td>
			</tr>
			<%
				for(HashMap<String, Object> m : rankList) {
			%>
					<tr>
						<td><%=m.get("이름")%></td>
						<td><%=m.get("급여")%></td>
						<td><%=m.get("순위")%></td>
					</tr>
			<%	
				}
			%>
		</table>
	</div>
	<div class="col-sm">
		<h1>dense_rank</h1>
		<table class="table">
			<tr>
				<td>이름</td>
				<td>급여</td>
				<td>순위</td>
			</tr>
			<%
				for(HashMap<String, Object> m : dense_rankList) {
			%>
					<tr>
						<td><%=m.get("이름")%></td>
						<td><%=m.get("급여")%></td>
						<td><%=m.get("순위")%></td>
					</tr>
			<%	
				}
			%>
		</table>
	</div>
	<div class="col-sm">
		<h1>row_number</h1>
		<table class="table">
			<tr>
				<td>이름</td>
				<td>급여</td>
				<td>순위</td>
			</tr>
			<%
				for(HashMap<String, Object> m : row_numberList) {
			%>
					<tr>
						<td><%=m.get("이름")%></td>
						<td><%=m.get("급여")%></td>
						<td><%=m.get("순위")%></td>
					</tr>
			<%	
				}
			%>
		</table>
	</div>
	<div class="col-sm">
		<h1>ntile</h1>
		<table class="table">
			<tr>
				<td>이름</td>
				<td>급여</td>
				<td>급여순위</td>
			</tr>
			<%
				for(HashMap<String, Object> m : ntileList) {
			%>
					<tr>
						<td><%=m.get("이름")%></td>
						<td><%=m.get("급여")%></td>
						<td><%=m.get("등급")%></td>
					</tr>
			<%	
				}
			%>
		</table>
	</div>
</div>
<%
	// 페이징 수
	int pagePerPage = 10;
	// 최소 페이지
	int minPage = (currentPage-1) / pagePerPage * pagePerPage + 1;
	// 최대 페이지
	int maxPage = minPage + pagePerPage - 1;
	// 최대 페이지가 마지막 페이지 보다 크면 최대 페이지 = 마지막 페이지
	if(maxPage > lastPage) {
		maxPage = lastPage;
	}
	// 이전 페이지
	// 최소 페이지가 1보타 클 경우 이전 페이지 표시
	if(minPage>1) {
%>
		<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
<%			
	}
	// 최소 페이지부터 최대 페이지까지 표시
	for(int i = minPage; i<=maxPage; i=i+1) {
		if(i == currentPage) {	// 현재페이지는 링크 비활성화
%>	
		<%=i%>
<%			
		}else {					// 현재페이지가 아닌 페이지는 링크 활성화
%>	
			<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=i%>"><%=i%></a>
<%				
		}
	}
	// 다음 페이지
	// 최대 페이지가 마지막 페이지와 다를 경우 다음 페이지 표시
	if(maxPage != lastPage) {
%>
		<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
<%	
	}
%>
</body>
</html>
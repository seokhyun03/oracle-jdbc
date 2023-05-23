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
	
	// start with connect by prior sql 전송
	String swcbpSql = "select 번호, 직급레벨, 사원ID, 이름, 상급자ID, 직급체계 from (select rownum 번호, 직급레벨, 사원ID, 이름, 상급자ID, 직급체계 from (select level 직급레벨, employee_id 사원ID, lpad(' ',level-1) || first_name 이름, manager_id 상급자ID, sys_connect_by_path(first_name,'-') 직급체계 from employees start with manager_id is null connect by prior employee_id = manager_id order siblings by first_name desc)) where 번호 between ? and ?";
	PreparedStatement swcbpStmt = conn.prepareStatement(swcbpSql);
	swcbpStmt.setInt(1,beginRow);
	swcbpStmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(swcbpStmt + " <-- start_with_connect_by_prior_list swcbpStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	ResultSet swcbpRs = swcbpStmt.executeQuery();
	ArrayList<HashMap<String, Object>> swcbpList = new ArrayList<HashMap<String, Object>>();
	while(swcbpRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("번호", swcbpRs.getString("번호"));
		m.put("직급레벨", swcbpRs.getString("직급레벨"));
		m.put("사원ID", swcbpRs.getString("사원ID"));
		m.put("이름", swcbpRs.getString("이름"));
		m.put("상급자ID", swcbpRs.getString("상급자ID"));
		m.put("직급체계", swcbpRs.getString("직급체계"));
		swcbpList.add(m);
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
		<h1>start with connect by prior</h1>
		<table class="table">
			<tr>
				<td>직급레벨</td>
				<td>사원ID</td>
				<td>이름</td>
				<td>상급자ID</td>
				<td>직급체계</td>
				
			</tr>
			<%
				for(HashMap<String, Object> m : swcbpList) {
			%>
					<tr>
						<td><%=m.get("직급레벨")%></td>
						<td><%=m.get("사원ID")%></td>
						<td><%=m.get("이름")%></td>
						<td><%=m.get("상급자ID")%></td>
						<td><%=m.get("직급체계")%></td>
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
		<a href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
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
			<a href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=i%>"><%=i%></a>
<%				
		}
	}
	// 다음 페이지
	// 최대 페이지가 마지막 페이지와 다를 경우 다음 페이지 표시
	if(maxPage != lastPage) {
%>
		<a href="<%=request.getContextPath()%>/start_with_connect_by_prior_list.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
<%	
	}
%>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	//현재페이지
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	//oracle db 접속
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
	
	// sql 전송
	PreparedStatement windowStmt = null;
	ResultSet windowRs = null;
	String windowSql = "select 번호, 직원ID, 이름, 급여, 전체급여평균, 전체급여합계, 전체사원수 from (select rownum 번호, employee_id 직원ID, last_name 이름, salary 급여, round(avg(salary) over()) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수 from employees) where 번호 between ? and ?";
	windowStmt = conn.prepareStatement(windowSql);
	windowStmt.setInt(1,beginRow);
	windowStmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(windowStmt + " <-- windowsFunctionEmpList windowStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	windowRs = windowStmt.executeQuery();
	ArrayList<HashMap<String, Object>> windowList = new ArrayList<HashMap<String, Object>>();
	while(windowRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("직원ID", windowRs.getString("직원ID")); 
		m.put("이름", windowRs.getString("이름"));
		m.put("급여", windowRs.getString("급여"));
		m.put("전체급여평균", windowRs.getString("전체급여평균"));
		m.put("전체급여합계", windowRs.getString("전체급여합계"));
		m.put("전체사원수", windowRs.getString("전체사원수"));
		windowList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
</head>
<body>
	<h1>windowFunctionEmpList</h1>
	<table border="1">
		<tr>
			<td>직원ID</td>
			<td>이름</td>
			<td>급여</td>
			<td>전체급여평균</td>
			<td>전체급여합계</td>
			<td>전체사원수</td>
		</tr>
		<%
			for(HashMap<String, Object> m : windowList) {
		%>
				<tr>
					<td><%=m.get("직원ID")%></td>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("급여")%></td>
					<td><%=m.get("전체급여평균")%></td>
					<td><%=m.get("전체급여합계")%></td>
					<td><%=m.get("전체사원수")%></td>
				</tr>
		<%	
			}
		%>
	</table>
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
			<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
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
				<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>
	<%				
			}
		}
		// 다음 페이지
		// 최대 페이지가 마지막 페이지와 다를 경우 다음 페이지 표시
		if(maxPage != lastPage) {
	%>
			<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%	
		}
	%>
</body>
</html>